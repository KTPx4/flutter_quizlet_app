const TopicModel = require("../models/TopicModel")
const CombineModel = require("../models/CombineWordModel")

module.exports.GetAll = async(req, res) =>{
    try{
        var Account = req.vars.User
        var idu = Account._id

        var ListTopic = await TopicModel.find({authorID: idu})
        if(!ListTopic || ListTopic.length < 1)
        {
            return res.status(200).json({
                message:"Chưa có topic nào. Hãy tạo thêm để xem",
                count: 0,
                data: null
            })
        }   
    
        var resultTopics =await formatListTopic(ListTopic)
        
    
        return res.status(200).json({
            message: "Lấy thành công danh sách topic",
            count: ListTopic.length,
            data: {
                topics: resultTopics
            }
        })
    }
    catch(err)
    {
        return res.status(500).json({
            message: "Server đang bận. Vui lòng thử lại sau!"
        })
    }

}

module.exports.GetByID = async(req, res) =>{
    let topicID = req.params.id

    var ListTopic = await TopicModel.find({_id: topicID})
    if(!ListTopic || ListTopic.length < 1)
    {
        return res.status(200).json({
            message:"Topic không tồn tại hoặc vừa bị xóa",
            count: 0,
            data: null
        })
    }   

    var resultTopics =await formatListTopic(ListTopic)    

    return res.status(200).json({
        message: `Lấy thành công Topic '${topicID}'`,
        data: {
            topics: resultTopics
        }
    })
}

module.exports.GetPublic = async (req, res) =>{
    try{

        var ListTopic = await TopicModel.find({isPublic: true})
        if(!ListTopic || ListTopic.length < 1)
        {
            return res.status(200).json({
                message:"Chưa có topic nào. Hãy tạo thêm để xem",
                count: 0,
                data: null
            })
        }   
    
        var resultTopics = await formatListTopic(ListTopic)
        
    
        return res.status(200).json({
            message: "Lấy thành công danh sách topic cộng đồng",
            count: ListTopic.length,
            data: {
                topics: resultTopics
            }
        })
    }
    catch(err)
    {
        return res.status(500).json({
            message: "Server đang bận. Vui lòng thử lại sau!"
        })
    }
}

module.exports.Add = async(req, res) =>{
    try{
        var Account = req.vars.User
        var idu = Account._id
        var {topicName, desc, isPublic, words} = req.body

        var newTopic = await TopicModel.create({
            topicName: topicName,
            desc: desc,
            authorID: idu,
            isPublic: isPublic
        })

        var idTopic = newTopic._id
        var listWords = await Promise.all(words.map(async (word) => {

            var newcombine = await CombineModel.create({
                topicID: idTopic,
                desc: word["desc"],
                img:  word["img"],
                mean1: {
                    title: word["mean1"]["title"],
                    lang: word["mean1"]["lang"]
                },
                mean2: {
                    title: word["mean2"]["title"],
                    lang: word["mean2"]["lang"]
                },             
              
            })
        
            return {
                "desc": newcombine.desc,
                "img": newcombine.img,
                mean1: newcombine.mean1,
                mean2: newcombine.mean2
            }
        }));
        
        var result = [{
            ...newTopic["_doc"],
            "words": listWords
        }]
        
        
        return res.status(200).json({
            message: "Thêm thành công topic",
            data: result[0]
        })

    }
    catch(err)
    {
        console.log("Error Add TopicController - Add: " , err);
        return res.status(500).json({
            message: "Thêm topic thất bại. Vui lòng thử lại sau!"
        })
    }



}

module.exports.Delete = async(req, res) => {
    try{
        let topicID = req.params.id
        var topic =await TopicModel.findOneAndDelete({_id: topicID})
        if(!topic)
        {
            return res.status(400).json({
                message: `Topic '${topicID}' không tồn tại`
            })
        }
        var words = await CombineModel.find({topicID: topicID})
        for(let word of words)
        {
            await CombineModel.findOneAndDelete({_id: word._id})   
        }
        // delete topic in folder - or set message: topic not has deleted

        return res.status(200).json({
            message: `Xóa thành công topic '${topicID}'`,
            data: topic
        })
    }
    catch(err)
    {
        return res.status(500).json({
            message: "Server đang bận. Vui lòng thử lại sau!"
        })
    }
}


const formatListWord = (listCombine) => {
    var listWords = []

    for(let word of listCombine)
    {
        listWords.push({
            "desc": word.desc,
            "img": word.img,
            "mean1": word.mean1,
            "mean2": word.mean2,
        })
    }
    return listWords
}

const formatListTopic = async (ListTopic) => {
    var resultTopics = await Promise.all(ListTopic.map(async (topic)=>{
        var listCombine = await CombineModel.find({topicID: topic._id})
        var listWords =  formatListWord(listCombine)

        return {
            ...topic["_doc"],
            "countWords": listCombine.length,
            "words": listWords
        }
    }))

    return resultTopics
}
