import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../shared/components/components.dart';
import '../../shared/network/cubit/cubit.dart';
import '../modules/about_us/about_us_screen.dart';
import '../modules/login/login_screen.dart';
import '../modules/profile/profile_screen.dart';
import '../modules/request_order/requests_cubit/requests_cubit.dart';
import '../modules/request_order/requests_cubit/requests_states.dart';
import '../shared/components/constants.dart';
import '../shared/network/cubit/states.dart';
import '../shared/network/local/cash_helper.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({Key? key}) : super(key: key);

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  String? selectedCity;
  String? selectedCompany;

  int _machineValue = 0;
  String selectedMachine = '';
  var machines = <String>[
    'الآلة؟',
    'آلة تصوير',
    'بروجيكتور',
    'شاشة',
  ];
  var locationMessage = '';
  bool locationIcon = false;
  double latitude = 0.0;
  double longitude = 0.0;

  void getCurrentLocation() async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();

    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      locationMessage = '${position.altitude}, ${position.longitude}';
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  final userData = FirebaseAuth.instance.currentUser;
  String name = '';
  String email = '';
  String image = '';

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var consultationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (BuildContext context, state) {},
      builder: (BuildContext context, state) {
        var user = FirebaseAuth.instance.currentUser;
        var height = MediaQuery.of(context).size.height;
        var width = MediaQuery.of(context).size.width;
        uId = CashHelper.getData(key: 'uId');
        city = CashHelper.getData(key: 'city');

        final Stream<QuerySnapshot> dataStream = FirebaseFirestore.instance
            .collection(city!)
            .doc(city)
            .collection('users')
            .snapshots();

        return Scaffold(
          appBar: AppBar(
            title: const Text('الرئيسية'),
            centerTitle: true,
          ),
          // **************************  The Drawer  ***************************
          endDrawer: Drawer(
            child: ListView(
              children: <Widget>[
                // Header
                UserAccountsDrawerHeader(
                  accountName: uId != null
                      ? Text('${user?.displayName}')
                      : const Text(''),
                  accountEmail: uId != null
                      ? Text('${user?.email}')
                      : Container(
                          width: width * 0.5,
                          padding: const EdgeInsets.only(
                              bottom: 15, left: 5, right: 60),
                          child: defaultButton(
                            onPressed: () {
                              navigateAndFinish(context, LoginScreen());
                            },
                            text: 'سجل الآن',
                            backgroundColor: Colors.deepOrange,
                          ),
                        ),
                  currentAccountPicture: image == ''
                      ? Image.network(
                          'https://icons-for-free.com/iconfiles/png/512/person-1324760545186718018.png',
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(
                            image,
                          ),
                        ),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                ),

                // Body
                SizedBox(
                  height: height * 0.03,
                ),

                InkWell(
                  onTap: () {
                    navigateAndFinish(context, const HomeLayout());
                  },
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('الرئيسية'),
                        SizedBox(
                          width: width * 0.1,
                        ),
                        const Icon(
                          Icons.home,
                          color: Colors.blue,
                        ),
                        SizedBox(
                          width: width * 0.03,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: height * 0.03,
                ),

                InkWell(
                  onTap: () {
                    navigateAndFinish(context, ProfileScreen());
                  },
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('الصفحة الشخصية'),
                        SizedBox(
                          width: width * 0.1,
                        ),
                        const Icon(
                          Icons.person,
                          color: Colors.green,
                        ),
                        SizedBox(
                          width: width * 0.03,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: height * 0.03,
                ),

                InkWell(
                  onTap: () {
                    AppCubit.get(context).changeAppModeTheme();
                  },
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('تغيير الثيم'),
                        SizedBox(
                          width: width * 0.1,
                        ),
                        Icon(
                          AppCubit.get(context).isDark
                              ? Icons.wb_sunny_outlined
                              : Icons.nightlight_outlined,
                          color: AppCubit.get(context).isDark
                              ? Colors.blue
                              : Colors.deepOrange,
                        ),
                        SizedBox(
                          width: width * 0.03,
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: height * 0.03,
                ),
                const Divider(thickness: 2),

                InkWell(
                  onTap: () {
                    navigateTo(context, const AboutUsScreen());
                  },
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('للتواصل'),
                        SizedBox(
                          width: width * 0.1,
                        ),
                        const Icon(
                          Icons.help,
                          color: Colors.blue,
                        ),
                        SizedBox(
                          width: width * 0.03,
                        ),
                      ],
                    ),
                  ),
                ),

                InkWell(
                  onTap: () {
                    signOut(context);
                  },
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('تسجيل الخروج'),
                        SizedBox(
                          width: width * 0.1,
                        ),
                        const Icon(
                          Icons.logout_outlined,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: width * 0.03,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ***********************  The Scaffold Body  ***********************
          body: RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: BlocProvider(
              create: (BuildContext context) => RequestCubit(),
              child: BlocConsumer<RequestCubit, RequestStates>(
                listener: (context, state) {},
                builder: (context, state) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: dataStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Something Wrong! ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        final List storeDocs = [];
                        snapshot.data!.docs
                            .map((DocumentSnapshot documentSnapshot) {
                          Map users =
                              documentSnapshot.data() as Map<String, dynamic>;
                          storeDocs.add(users);
                          users['uId'] = documentSnapshot.id;
                        }).toList();

                        return ListView.builder(
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: height * 0.03,
                                      ),

                                      /*StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('machineTypes')
                              .snapshots(),
                          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            int i = 0;
                            if (!snapshot.hasData) {
                              return const Text('Loading');
                            } else {
                              final List<DropdownMenuItem<String>> cities = [];
                              String? selectedCity;
                              for (i = 0; i < snapshot.data!.docs.length; i++) {
                                DocumentSnapshot snap = snapshot.data!.docs[i];
                                Map city = snap.data() as Map<String, dynamic>;
                                cities.add(
                                  DropdownMenuItem(
                                    value: city['machineTypeName'],
                                    child: Text(city['machineTypeName']),
                                  ),
                                );
                              }
                              return DropdownButton(
                                value: selectedCity,
                                //isExpanded: false,
                                hint: const Text('المؤسسة؟'),
                                items: cities,
                                onChanged: (value) {
                                  setState(() {
                                    selectedCity = value;
                                  });
                                },
                              );
                            }
                          },
                        ),*/
                                      // City ListTile with DropdownButton
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.grey[300],
                                        ),
                                        child: ListTile(
                                          trailing: const Text(
                                            'المدينة',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                            ),
                                          ),
                                          leading: Text(
                                            storeDocs[index]['area'],
                                            style: const TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: height * 0.03,
                                      ),

                                      // School ListTile with DropdownButton
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.grey[300],
                                        ),
                                        child: ListTile(
                                          trailing: const Text(
                                            'المدرسة',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                            ),
                                          ),
                                          leading: Text(
                                            storeDocs[index]['school'],
                                            style: const TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: height * 0.03,
                                      ),
                                      // Machine ListTile with DropdownButton
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.grey[300],
                                        ),
                                        child: ListTile(
                                          trailing: const Text(
                                            'إختار الآلة',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                            ),
                                          ),
                                          leading: DropdownButton<String>(
                                            hint: const Text('الآلة'),
                                            value: machines[_machineValue],
                                            items:
                                                machines.map((String machine) {
                                              return DropdownMenuItem<String>(
                                                value: machine,
                                                child: Text(
                                                  machine,
                                                  style: const TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _machineValue =
                                                    machines.indexOf(value!);
                                                selectedMachine =
                                                    value.toString();
                                              });
                                            },
                                          ),
                                        ),
                                      ),

                                      // Machine Type ListTile with DropdownButton
                                      /*Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[300],
                          ),
                          child: ListTile(
                            trailing: const Text(
                              'نوع الآله',
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                            ),
                            leading: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('machineTypes')
                                  .snapshots(),
                              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                int i = 0;
                                if (!snapshot.hasData) {
                                  return const Text('Loading');
                                } else {
                                  final List<DropdownMenuItem<String>> machineTypes = [];
                                  for (i = 0; i < snapshot.data!.docs.length; i++) {
                                    DocumentSnapshot snap = snapshot.data!.docs[i];
                                    Map machineType = snap.data() as Map<String, dynamic>;
                                    machineTypes.add(
                                      DropdownMenuItem(
                                        value: machineType['machineTypeName'],
                                        child: Text(machineType['machineTypeName']),
                                      ),
                                    );
                                  }
                                  return DropdownButton(
                                    value: selectedMachineType,
                                    //isExpanded: false,
                                    hint: const Text('نوع الآلة؟'),
                                    items: machineTypes,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedMachineType = value;
                                      });
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ),*/
                                      SizedBox(
                                        height: height * 0.03,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.grey[300],
                                        ),
                                        child: ListTile(
                                          trailing: const Text(
                                            '<----   اضغط لتحديد الموقع',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                            ),
                                          ),
                                          leading: IconButton(
                                            onPressed: () {
                                              getCurrentLocation();
                                              RequestCubit.get(context)
                                                  .changeLocationIcon();
                                            },
                                            icon: Icon(
                                              RequestCubit.get(context)
                                                  .locationIcon,
                                              color: RequestCubit.get(context)
                                                      .isLocation
                                                  ? Colors.blue
                                                  : Colors.green,
                                              size: 30.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: height * 0.03,
                                      ),

                                      // Consultation TextField
                                      SizedBox(
                                        width: width * 0.8, //height: 350,
                                        child: TextFormField(
                                          controller: consultationController,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'برجاء كتابة الإستفسار';
                                            }
                                            return null;
                                          },
                                          textDirection: TextDirection.rtl,
                                          maxLines: 5,
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1
                                              ?.copyWith(
                                                color:
                                                    AppCubit.get(context).isDark
                                                        ? Colors.black
                                                        : Colors.white,
                                              ),
                                          textAlign: TextAlign.end,
                                          decoration: const InputDecoration(
                                            hintText: ' !اكتب استفسارك',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              vertical: 20,
                                              horizontal: 15,
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: height * 0.03,
                                      ),

                                      ConditionalBuilder(
                                        condition:
                                            state is! RequestLoadingState,
                                        builder: (context) => defaultButton(
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              var city =
                                                  storeDocs[index]['area'];
                                              var school =
                                                  storeDocs[index]['school'];
                                              var phone =
                                                  storeDocs[index]['phone'];
                                              var machine = selectedMachine;
                                              var consultation =
                                                  consultationController.text;

                                              if (machine.isEmpty &&
                                                  consultationController
                                                      .text.isEmpty &&
                                                  latitude == 0.0 &&
                                                  longitude == 0.0) {
                                                return showToast(
                                                  message:
                                                      'تأكد من تحديد موقعك وإختيار الألة وكتابة الإستفسار!',
                                                  state: ToastStates.ERROR,
                                                );
                                              } else {
                                                RequestCubit.get(context)
                                                    .userRequest(
                                                  city: city.toString(),
                                                  school: school.toString(),
                                                  phone: phone.toString(),
                                                  machine: machine.toString(),
                                                  latitude: latitude,
                                                  longitude: longitude,
                                                  consultation:
                                                      consultation.toString(),
                                                );
                                                setState(() {
                                                  consultationController.text =
                                                      '';
                                                  selectedMachine = '';
                                                  _machineValue = 0;
                                                  RequestCubit.get(context)
                                                          .locationIcon =
                                                      Icons
                                                          .add_location_alt_outlined;
                                                  RequestCubit.get(context)
                                                      .isLocation = false;
                                                });

                                                showToast(
                                                  message:
                                                      'تم إرسال طلبك بنجاح',
                                                  state: ToastStates.SUCCESS,
                                                );
                                              }
                                            }
                                          },
                                          text: 'إرسال',
                                          backgroundColor:
                                              AppCubit.get(context).isDark
                                                  ? Colors.blue
                                                  : Colors.deepOrange,
                                        ),
                                        fallback: (context) => const Center(
                                            child: CircularProgressIndicator()),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
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
          ),
        );
      },
    );
  }
}
