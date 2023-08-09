import 'package:flutter/material.dart';

class SideMenuWidget extends StatelessWidget {
  final ValueChanged onResult;
  const SideMenuWidget({super.key, required this.onResult});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 75.0,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: ThemeData.light().primaryColor,
              ),
              child: const Text(
                'Сохраненные запросы',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                return ListTile(
                  //TODO визуал
                  //TODO добавляем запросы из сохраненных
                  title: ListTile(
                    title: Text("Search $index"),
                    onTap: (){
                      Navigator.of(context).pop();
                      onResult("Search $index");
                    },
                  ),
                );
              })
        ],
      ),
    );
  }
}
