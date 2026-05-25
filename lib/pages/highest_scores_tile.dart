import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HighestScoresTile extends StatelessWidget {
  final String documentId;
  const HighestScoresTile({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    //get the collection of highestScores
    CollectionReference highestScores = FirebaseFirestore.instance.collection(
      "highestscores",
    );
    return FutureBuilder<DocumentSnapshot>(
      future: highestScores.doc(documentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Row(
            children: [
              Text(data["name"], style: TextStyle(color: Colors.white)),
              SizedBox(width: 10),
              Text(
                data['score'].toString(),
                style: TextStyle(color: Colors.white),
              ),
            ],
          );
        } else {
          return Text('Loading', style: TextStyle(color: Colors.white));
        }
      },
    );
  }
}
