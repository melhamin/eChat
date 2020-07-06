import 'package:flutter/material.dart';
import 'package:whatsapp_clone/providers/person.dart';
import 'package:whatsapp_clone/widgets/chat_item.dart';

class ChatsScreen extends StatelessWidget {
  final List<Person> dummyData = [
    Person(
      name: 'Sam',
      textToShow: 'Hey what up?',
      imageUrl:
          'https://www.readersdigest.ca/wp-content/uploads/2017/08/being-a-good-person.jpg',
    ),
    Person(
      name: 'Angela',
      textToShow: 'Are we meeting today?',
      imageUrl:
          'https://basicknowledgecouk.files.wordpress.com/2018/07/pexels-photo-733872.jpeg',
    ),
    Person(
      name: 'Ahmed',
      textToShow: 'Yo where are you?',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTCDaHuOyNanVVgEcANjLG5lq3eQbU_Lv3wC73b08qUsQ&usqp=CAU&ec=45673586',
    ),
    Person(
      name: 'Anna',
      textToShow: 'We are here...',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTcs66k1d0BuqhtO14B8sNTt514YGDnxOx2H6y22_sqBw&usqp=CAU&ec=45673586',
    ),
    Person(
      name: 'Ali',
      textToShow: 'I am waiting outside the building',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRAi5PWUxzo7t3nzimuuAZB3Okllr-2c49A8bA7vL9a5w&usqp=CAU&ec=45673586',
    ),
    Person(
      name: 'Gabby',
      textToShow: 'Come to the A building',
      imageUrl:
          'https://img01.imgsinemalar.com/images/afis_buyuk/k/katheryn-winnick-1499437601.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: dummyData.length,
      itemBuilder: (ctx, i) {
        return ChatItem(dummyData[i]);
      },
      separatorBuilder: (ctx, i) {
        return Divider(
          indent: 85,
          endIndent: 15,
          color: Colors.black.withOpacity(0.12),
        );
      },
    );
  }
}
