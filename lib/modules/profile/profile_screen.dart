import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../layout/home_layout.dart';
import '../../shared/components/components.dart';
import '../../shared/components/constants.dart';
import '../../shared/network/cubit/cubit.dart';
import '../../shared/network/cubit/states.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late var formKey = GlobalKey<FormState>();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();
  final userData = FirebaseAuth.instance.currentUser;
  String name = '';
  String email = '';
  String image = '';
  String cover = '';
  String phone = '';
  String label = '';

  final CollectionReference users = FirebaseFirestore.instance
      .collection(city!)
      .doc(city)
      .collection('users');

  Future getUserData() async {
    await FirebaseFirestore.instance
        .collection(city!)
        .doc(city)
        .collection('users')
        .doc(userData!.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        setState(() {
          name = snapshot.data()!['name'];
          email = snapshot.data()!['email'];
          image = snapshot.data()!['image'];
          cover = snapshot.data()!['cover'];
          phone = snapshot.data()!['phone'];
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> dataStream = FirebaseFirestore.instance
        .collection(city!)
        .doc(city)
        .collection('users')
        .snapshots();

    var cubit = AppCubit.get(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: defaultTextButton(
              onPressed: () {
                navigateAndFinish(context, const HomeLayout());
              },
              text: 'خروج',
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: BlocConsumer<AppCubit, AppStates>(
          listener: (context, state) {},
          builder: (context, state) {
            var height = MediaQuery.of(context).size.height;

            return StreamBuilder<QuerySnapshot>(
              stream: dataStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something Wrong! ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final List storeDocs = [];
                  snapshot.data!.docs.map((DocumentSnapshot documentSnapshot) {
                    Map users = documentSnapshot.data() as Map<String, dynamic>;
                    storeDocs.add(users);
                    users['uId'] = documentSnapshot.id;
                  }).toList();
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: formKey,
                      child: ListView(
                        children: [
                          SizedBox(
                            height: height * 0.25,

                            // ******************** Stack of Cover Image ********************
                            child: Stack(
                              alignment: AlignmentDirectional.bottomCenter,
                              children: [
                                Align(
                                  alignment: AlignmentDirectional.topCenter,
                                  child: Stack(
                                    alignment: AlignmentDirectional.topEnd,
                                    children: [
                                      SizedBox(
                                        height: height * 0.19,
                                        width: double.infinity,
                                        child: cover == ''
                                            ? const Image(
                                                image: NetworkImage(
                                                  'https://cdn.quotesgram.com/img/54/5/1828314355-ayat-kareema-islamic-fb-cover.png',
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                            : Image(
                                                image: NetworkImage(
                                                  cover,
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          cubit.pickUploadCoverImage();
                                          coverImage = cover;
                                        },
                                        icon: const CircleAvatar(
                                          radius: 20.0,
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 18.0,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ****************** Stack of Profile Image ********************
                                Stack(
                                  alignment: AlignmentDirectional.bottomEnd,
                                  children: [
                                    CircleAvatar(
                                      radius: 64.0,
                                      backgroundColor: cubit.isDark
                                          ? Theme.of(context)
                                              .scaffoldBackgroundColor
                                          : const Color(0xffF4F2F2),
                                      child: CircleAvatar(
                                        radius: 60.0,
                                        child: image == ''
                                            ? CircleAvatar(
                                                backgroundColor:
                                                    Colors.grey[300],
                                                radius: 60.0,
                                                backgroundImage:
                                                    const NetworkImage(
                                                  'https://icons-for-free.com/iconfiles/png/512/person-1324760545186718018.png',
                                                ),
                                              )
                                            : CircleAvatar(
                                                radius: 60.0,
                                                backgroundImage: NetworkImage(
                                                  image,
                                                ),
                                              ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        cubit.pickUploadProfileImage();
                                        profileImage = image;
                                      },
                                      icon: const CircleAvatar(
                                        radius: 20.0,
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 18.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: height * 0.015,
                          ),
                          Text(
                            'Name : $name',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                ?.copyWith(fontSize: 17),
                          ),
                          SizedBox(
                            height: height * 0.012,
                          ),
                          Text(
                            'Email : ${userData!.email}',
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.caption?.copyWith(
                                      fontSize: 14.0,
                                      color: cubit.isDark
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                          ),
                          SizedBox(
                            height: height * 0.012,
                          ),
                          const Divider(
                            thickness: 1.5,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Container(
                              padding: const EdgeInsets.only(right: 20.0),
                              alignment: Alignment.centerRight,
                              child: Text(
                                'تحديث',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: height * 0.015,
                          ),
                          // TextFormField of Name
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: defaultButton(
                                    onPressed: () async {
                                      final String phone = phoneController.text;

                                      await users.doc(userData!.uid).update({
                                        'phone': phone,
                                      });
                                      phoneController.text = '';
                                      showToast(
                                        message: 'تم التحديث بنجاح',
                                        state: ToastStates.SUCCESS,
                                      );
                                      setState(() {
                                        label = phone;
                                      });
                                    },
                                    text: 'تحديث',
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: defaultTextFormField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.phone,
                                  label: phone,
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .subtitle1
                                      ?.copyWith(
                                        color: AppCubit.get(context).isDark
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'برجاء كتابة رقم الهاتف للتحديث!';
                                    }
                                    return null;
                                  },
                                  suffix: Icons.phone,
                                  prefixColor: AppCubit.get(context).isDark
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: height * 0.015,
                          ),

                          // TextFormField of Password
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: defaultButton(
                                    onPressed: () async {
                                      await openDialog();
                                      //navigateAndFinish(context, const ResetPasswordScreen());
                                    },
                                    text: 'تحديث',
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.grey[300],
                                  ),
                                  child: const ListTile(
                                    title: Text(
                                      'الرقم السري',
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontSize: 18.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: height * 0.015,
                          ),

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 50.0),
                            child: defaultButton(
                              onPressed: () async {
                                //navigateAndFinish(context, const HomeLayout());
                                await users.doc(userData!.uid).update({
                                  'image': cubit.profileImageUrl,
                                  'cover': cubit.coverImageUrl,
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'إضغط مرة أخرى للحفظ والخروج',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    duration: const Duration(
                                      seconds: 5,
                                    ),
                                    action: SnackBarAction(
                                      label: 'حفظ',
                                      onPressed: () async {
                                        await users.doc(userData!.uid).update({
                                          'image': cubit.profileImageUrl,
                                          'cover': cubit.coverImageUrl,
                                        });
                                        navigateAndFinish(
                                            context, const HomeLayout());
                                      },
                                    ),
                                  ),
                                );
                              },
                              text: 'تحديث',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<String?> openDialog() => showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('أدخل الإيميل الخاص بك'),
          content: defaultTextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            label: 'الايميل',
            textStyle: Theme.of(context).textTheme.subtitle1?.copyWith(
                  color: AppCubit.get(context).isDark
                      ? Colors.black
                      : Colors.white,
                ),
            validator: (String? value) {
              if (value!.isEmpty) {
                return 'Please Enter City Name';
              }
              if (!RegExp("^[a-zA-Z0-9_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                  .hasMatch(value)) {
                return 'برجاء ادخال ايميل صحيح';
              }
              return null;
            },
            suffix: Icons.email,
            prefixColor:
                AppCubit.get(context).isDark ? Colors.black : Colors.white,
          ),
          actions: [
            defaultTextButton(
              onPressed: () {
                passwordReset();
                emailController.clear();
                navigateAndFinish(context, const HomeLayout());
              },
              text: 'إرسال',
            ),
          ],
        ),
      );

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content:
                  Text('تم إرسال لينك تغيير الباسورد برجاء التوجه الى الإيميل'),
            );
          });
    } on FirebaseAuthException catch (error) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(error.message.toString()),
            );
          });
    }
  }
}
