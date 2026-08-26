import 'package:flutter/material.dart';

import 'checklist_card.dart';


class ChecklistList extends StatelessWidget {
  ChecklistList({super.key});


  final List<Map<String,String>> data = [

    {
      "id":"#001",
      "name":"Daily Train Inspection",
      "category":"Rolling Stock",
      "jobPlan":"Daily Inspection",
      "schedule":"Every Day",
    },


    {
      "id":"#002",
      "name":"Brake Inspection",
      "category":"Safety",
      "jobPlan":"Weekly Check",
      "schedule":"Weekly",
    },

  ];


  @override
  Widget build(BuildContext context){

    return ListView.builder(

      itemCount:data.length,

      itemBuilder:(context,index){

        final item=data[index];

        return ChecklistCard(
          id:item["id"]!,
          name:item["name"]!,
          category:item["category"]!,
          jobPlan:item["jobPlan"]!,
          schedule:item["schedule"]!,
        );

      },
    );
  }
}