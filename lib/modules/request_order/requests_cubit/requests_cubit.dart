import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/request_model.dart';
import '../../../models/user_model.dart';
import 'requests_states.dart';

class RequestCubit extends Cubit<RequestStates>
{
  RequestCubit() : super(RequestInitialState());

  static RequestCubit get(context) => BlocProvider.of(context);

  void userRequest(
      {
        required String city,
        required String school,
        required String phone,
        required String machine,
        required double latitude,
        required double longitude,
        required String consultation,
      })
  {
    emit(RequestLoadingState());
    var companyName = FirebaseAuth.instance.currentUser?.displayName;

    FirebaseFirestore.instance.collection(city).doc(city).collection('requests').doc().get().then((value)
    {
      print(city);

      createUser(
        city: city,
        companyName: companyName.toString(),
        school: school,
        phone: phone,
        machine: machine,
        latitude: latitude,
        longitude: longitude,
        uId: value.id.toString(),
        consultation: consultation.toString(),
        //isEmailVerified: value.user!.emailVerified.toString(),
      );
    }).catchError((error)
    {
      emit(RequestErrorState(error.toString()));
    });
  }

  void createUser(
      {
        required String city,
        required String companyName,
        required String school,
        required String phone,
        required String machine,
        required double latitude,
        required double longitude,
        required String uId,
        required String consultation,
      })
  {

    RequestModel model = RequestModel(
      city: city,
      companyName: companyName,
      school: school,
      phone: phone,
      machine: machine,
      latitude: latitude,
      longitude: longitude,
      uId: uId,
      consultation: consultation,
    );

    FirebaseFirestore.instance
        .collection(city).doc(city).collection('requests').doc().set(model.toJson())
        .then((value)
    {
      emit(CreateRequestSuccessState());
    }).catchError((error)
    {
      emit(CreateRequestErrorState(error.toString()));
    });
  }

  IconData locationIcon = Icons.add_location_alt_outlined;
  bool isLocation = false;
  void changeLocationIcon()
  {
    isLocation = !isLocation;
    locationIcon = isLocation ? Icons.add_location_alt_outlined : Icons.done_all;

    emit(ChangeLocationIconState());
  }

  Stream<List<UserModel>> readUserData() =>
      FirebaseFirestore.instance.collection('جازان').doc('جازان').collection('users')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList());


}