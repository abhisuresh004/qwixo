import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class chatservice{
  final FirebaseFirestore _firestore= FirebaseFirestore.instance;

  String getchatid(String user1, String user2){
    final ids=[user1,user2];
    ids.sort();
    return ids.join();
    
  }

  Future<void> sendmessage({
    required String senderid,
    required String receiverid,
    required  String message

  })async{
    final chatid=getchatid(senderid, receiverid);
    final messageref=_firestore
    .collection('chats').doc(chatid).collection('message').doc();

    await messageref.set({
      'messageid':messageref.id,
      'senderid':senderid,
      'receiverid':receiverid,
      'text':message,
      'timestamp':FieldValue.serverTimestamp()

  });
    
  }
  Stream<QuerySnapshot>getmessages(String user1,String user2){
    final chatid=getchatid(user1, user2);
    return _firestore
    .collection('chats').doc(chatid).collection('message')
    .orderBy('timestamp',descending: true).snapshots();
  }
}