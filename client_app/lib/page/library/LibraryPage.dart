import 'package:client_app/component/AppBarCustom.dart';
import 'package:client_app/modules/ColorsApp.dart';
import 'package:client_app/modules/callFunction.dart';
import 'package:client_app/page/library/FolderTab.dart';
import 'package:client_app/page/topic/TopicPage.dart';
import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  GlobalKey<State<AppBarCustom>>? appBarKey ;
  LibraryPage({this.appBarKey,super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with SingleTickerProviderStateMixin{
  late final _tabController = TabController(length: 2, vsync: this);
  var _pageController = PageController();
  final CallFunction callFuntion = CallFunction();

  var childLib = [];

  bool isTopic = true; // use for button add in AppBar
 
  @override
  void initState() {
    // TODO: implement initState
    initStartup();
    super.initState();
  }

  void initStartup() async 
  {
   
    var action = _actionAppBar();

    if (widget.appBarKey?.currentState != null) 
    {

      (widget.appBarKey?.currentState as AppBarCustomState ).updateTitle("Thư viện");
      (widget.appBarKey?.currentState as AppBarCustomState ).updateAction(action);
  
    }
    
  }

  List<Widget> _actionAppBar()
  {
    return [
      IconButton(onPressed: (){}, icon: Icon(Icons.add))
    ];
  }
  //////

  void _animationToPage(index)
  {
    setState(() {
      isTopic = !isTopic;
    });

    _pageController.animateToPage(index, duration: const Duration(milliseconds: 200),
                              curve: Curves.linear);

    _tabController.animateTo(index, duration: const Duration(milliseconds: 200),
                              curve: Curves.linear);
                              
  }
  
  Widget _buildTabBar()
  {
    return Container(
        color: AppColors.libTabBar,
        child: TabBar(
        onTap: _animationToPage,      
        controller: _tabController,
        tabs: [
          Tab(icon: Icon(Icons.library_books_outlined),),
          Tab(icon: Icon(Icons.folder_copy_outlined),),
        ]),
    );
  }

  Future<Widget> _buildPage() async
  {
    if(childLib.length == 0)
    {
      childLib = [TopicPage(callFunction: callFuntion,), FolderTab()];
    }

    return PageView.builder(
      onPageChanged: _animationToPage,
      controller: _pageController,
      itemBuilder:  (context, index) => 
        Container(
          child: childLib[index],
        ),
      itemCount: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(onPressed: ()
            {
              callFuntion.refreshWidget();
            }, child: Text("Test Refresh")),
        _buildTabBar(),
        Expanded(child: FutureBuilder(future: _buildPage(), builder: (context, snapshot) {
          if(!snapshot.hasData)
          {
            return CircularProgressIndicator();
          }
          else if(snapshot.hasData)
          {
            var page = snapshot.data;
            return page!;
          }
          else
          {
            return Center(child: Text("Error When loading"),);
          }
        },))
      ],
    );
  }


  
}