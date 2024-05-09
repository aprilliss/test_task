import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pulsator/pulsator.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:test_task/home/bloc/home_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(const HomeLoadEvent()),
      child: const HomeLayout(),
    );
  }
}

class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeBloc bloc = BlocProvider.of<HomeBloc>(context);

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final String formattedTime =
            '${state.duration.inHours}:${state.duration.inMinutes}:${(state.duration.inSeconds % 60).toString().padLeft(2, '0')}';

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              actions: [
                DropdownButton<int>(
                  value: state.languageValue,
                  items: const [
                    DropdownMenuItem<int>(value: 1, child: Text('US')),
                    DropdownMenuItem<int>(value: 2, child: Text('DE'))
                  ],
                  onChanged: (value) {
                    bloc.add(ChangeLocaleEvent(value: value!));
                    switch (value) {
                      case 1:
                        context.setLocale(const Locale('en', 'US'));
                        break;
                      case 2:
                        context.setLocale(const Locale('de', 'DE'));
                        break;
                      default:
                        debugPrint('Error language');
                    }
                  },
                )
              ],
              title: Text(context.tr('title')),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Tab 1'),
                  Tab(text: 'Tab 2'),
                  Tab(text: 'Tab 3'),
                ],
              ),
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildFirstTab(formattedTime, context, state, bloc),
                _buildSecondTab(state, bloc, context),
                _buildThirdTab(context),
              ],
            ), /**/
          ),
        );
      },
    );
  }

  Widget _buildThirdTab(BuildContext context) {
    const String url =
        'https://energise.notion.site/Flutter-f86d340cadb34e9cb1ef092df4e566b7';
    return Table(
      children: [
        TableRow(children: [
          TextButton(
              onPressed: () async {
                RateMyApp rateMyApp = RateMyApp(
                  preferencesPrefix: 'rateMyApp_',
                  minDays: 7,
                  minLaunches: 10,
                  remindDays: 7,
                  remindLaunches: 10,
                  googlePlayIdentifier: 'fr.skyost.example',
                  appStoreIdentifier: '1491556149',
                )
                  ..init();
                rateMyApp.showStarRateDialog(
                  context,
                  title: context.tr('rate_us_title'), // The dialog title.
                  message: context.tr('rate_us_message'), // The dialog message.
                  // contentBuilder: (context, defaultContent) => content, // This one allows you to change the default dialog content.
                  actionsBuilder: (context, stars) {
                    // Triggered when the user updates the star rating.
                    return [
                      // Return a list of actions (that will be shown at the bottom of the dialog).
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () async {
                          // You can handle the result as you want (for instance if the user puts 1 star then open your contact page, if he puts more then open the store page, etc...).
                          // This allows to mimic the behavior of the default "Rate" button. See "Advanced > Broadcasting events" for more information :
                          await rateMyApp
                              .callEvent(RateMyAppEventType.rateButtonPressed);
                          Navigator.pop<RateMyAppDialogButton>(
                              context, RateMyAppDialogButton.rate);
                        },
                      ),
                    ];
                  },

                  dialogStyle: const DialogStyle(
                    // Custom dialog styles.
                    titleAlign: TextAlign.center,
                    messageAlign: TextAlign.center,
                    messagePadding: EdgeInsets.only(bottom: 20),
                  ),
                  starRatingOptions:
                      const StarRatingOptions(), // Custom star bar rating options.
                  onDismissed: () => rateMyApp.callEvent(RateMyAppEventType
                      .laterButtonPressed), // Called when the user dismissed the dialog (either by taping outside or by pressing the "back" button).
                );
              },
              child: Text(context.tr('rate_app'))),
          TextButton(
              onPressed: () {
                Share.shareUri(Uri.parse('https://example.com'));
              },
              child: Text(context.tr('share_app'))),
          TextButton(
              onPressed: () async {
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                }
              },
              child: Text(context.tr('contact_us')))
        ])
      ],
    );
  }

  Widget _buildSecondTab(HomeState state, HomeBloc bloc, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RefreshIndicator(
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: () async {
          bloc.add(RefreshEvent());
        },
        child: ListView(
          children: [
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: state.initialPosition,
                markers: {state.marker},
                myLocationEnabled: true,
                zoomControlsEnabled: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                  '${context.tr('coordinates')}: (${state.geoData?.latitude ?? 0}, ${state.geoData?.longitude ?? 0})'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                  '${context.tr('city')}: ${state.geoData?.city ?? ''}, ${state.geoData?.country ?? ''}'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('${context.tr('timezone')}: ${state.geoData?.timezone ?? ''}'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('IP: ${state.geoData?.ip ?? ''}'),
            ),
            TextButton(
                onPressed: () {
                  bloc.add(RefreshEvent());
                },
                child: Text(context.tr('reload')))
          ],
        ),
      ),
    );
  }

  Center _buildFirstTab(String formattedTime, BuildContext context,
      HomeState state, HomeBloc bloc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(formattedTime),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: Animate(
              effects: const [
                FadeEffect(),
                ScaleEffect(),
              ],
              child: state.isPaused
                  ? Pulsator(
                      style: const PulseStyle(
                        color: Colors.red,
                        startSize: 0,
                      ),
                      count: 1,
                      child: IconButton(
                        color: const Color.fromARGB(255, 245, 115, 115),
                        icon: const Icon(Icons.play_arrow, size: 72),
                        onPressed: () => bloc.add(const OnButtonStartEvent()),
                      ),
                    )
                  : IconButton(
                      color: const Color.fromARGB(255, 245, 115, 115),
                      icon: const Icon(Icons.pause, size: 72),
                      onPressed: () => bloc.add(const OnButtonStopEvent()),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
