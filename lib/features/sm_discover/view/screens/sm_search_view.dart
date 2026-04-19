import 'package:common_package/common_package.dart';
import 'package:dllni_user_app/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/widgets/download_more.dart';
import '../../../../core/widgets/failure_widget.dart';
import '../../../../core/widgets/loading_list.dart';
import '../../../../core/widgets/search_field_with_voice.dart';
import '../../../../core/widgets/search_with_type_dropdown.dart';
import '../../domain/usecases/browse_products_use_case.dart';
import '../../domain/usecases/browse_stores_use_case.dart';
import '../manager/bloc/sm_discover_bloc.dart';
import '../widgets/product_card.dart';
import '../widgets/searches_group.dart';
import '../widgets/smart_search_sheet.dart';
import '../widgets/store_card.dart';

class SmSearchView extends StatefulWidget {
  const SmSearchView({super.key, required this.type, this.initialSearch});
  final SearchType type;
  final String? initialSearch;

  @override
  State<SmSearchView> createState() => _SmSearchViewState();
}

class _SmSearchViewState extends State<SmSearchView> {
  late List<String> searchHistory;
  late TextEditingController searchController;
  bool isSearching = false;

  late SpeechToText speechToText;
  bool isListening = false;

  bool _speechInitialized = false;
  bool voiceCancelledByUser = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24 + MediaQuery.paddingOf(context).top),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Builder(
            builder: (context) {
              return SearchFieldWithVoice(
                backgroundColor: Color(0xFFF9FAFB),
                controller: searchController,
                hintText: widget.type == SearchType.product
                    ? "ابحث عن منتج..."
                    : "ابحث عن متجر...",
                onVoiceTap: widget.type == SearchType.store
                    ? null
                    : () async {
                        final words = await showModalBottomSheet<List<String>>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => const SmartSearchSheet(),
                        );
                        if (!context.mounted ||
                            words == null ||
                            words.isEmpty) {
                          return;
                        }
                        final query = words.join(' , ');
                        makeSearch(context, query);
                        searchHistory.removeWhere((word) => word == query);
                        searchHistory.insert(0, query);
                        setState(() {});
                        SharedPreferencesHelper.sharedPreferences!
                            .setStringList(Constants.searchKey, searchHistory);
                      },
                // isListening
                // ? () => _stopListening(context)
                // : () => _startListening(context),
                isListening: isListening,
                onSearch: (search) {
                  if (search.trim().isEmpty) return;
                  search = search.trim();
                  makeSearch(context, search);
                  searchHistory.removeWhere((word) => word == search);
                  searchHistory.insert(0, search);
                  setState(() {});
                  SharedPreferencesHelper.sharedPreferences!.setStringList(
                    Constants.searchKey,
                    searchHistory,
                  );
                },
              );
            },
          ),
        ),
        if (isSearching)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: AppText(
                    "نتائج البحث",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 26 / 14,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: widget.type == SearchType.product
                      ? BlocBuilder<SmDiscoverBloc, SmDiscoverState>(
                          buildWhen: (previous, current) =>
                              previous.browseProducts != current.browseProducts,
                          builder: (context, state) {
                            return state.browseProducts!.builder(
                              loadingWidget: Padding(
                                padding: const EdgeInsets.all(20),
                                child: LoadingGrid(
                                  heightCard: 232,
                                  borderRadius: 24,
                                  length: 10,
                                  crossAxisSpacing: 7,
                                  mainAxisSpacing: 12,
                                ),
                              ),
                              emptyWidget: Center(
                                child: AppText.labelMedium(
                                  'لا يوجد منتجات',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              successWidget: () {
                                return GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 7,
                                    mainAxisSpacing: 12,
                                    mainAxisExtent: 232,
                                  ),
                                  padding: EdgeInsetsDirectional.all(20),
                                  itemBuilder: (context, index) {
                                    if (state.browseProducts!.length <= index) {
                                      if (state.browseProducts!.length ==
                                          index) {
                                        context.read<SmDiscoverBloc>().add(
                                          BrowseProductsEvent(
                                            isReload: false,
                                            params: BrowseProductsParams(
                                              page: state
                                                  .browseProducts!
                                                  .pageNumber,
                                            ),
                                          ),
                                        );
                                      }
                                      return DownloadMore();
                                    }
                                    return ProductCard(
                                      product: state.browseProducts![index],
                                    );
                                  },
                                  // separatorBuilder: (context, index) =>
                                  //     SizedBox(height: 16),
                                  itemCount: state.browseProducts!.listLength(
                                    1,
                                  ),
                                );
                              },
                              failedWidget: Center(
                                child: FailureWidget(
                                  message: state.errorMessage.toString(),
                                  onRetry: () {},
                                ),
                              ),
                              onTapRetry: () {},
                            );
                          },
                        )
                      : BlocBuilder<SmDiscoverBloc, SmDiscoverState>(
                          buildWhen: (previous, current) =>
                              previous.browseStores != current.browseStores,
                          builder: (context, state) {
                            return state.browseStores!.builder(
                              loadingWidget: Padding(
                                padding: const EdgeInsets.all(20),
                                child: LoadingGrid(
                                  heightCard: 180,
                                  borderRadius: 24,
                                  length: 6,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 16,
                                ),
                              ),
                              emptyWidget: Center(
                                child: AppText.labelMedium(
                                  'لا يوجد متاجر',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              successWidget: () {
                                return GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 16,
                                        mainAxisExtent: 180,
                                      ),
                                  padding: EdgeInsetsDirectional.all(20),
                                  itemBuilder: (context, index) {
                                    if (state.browseStores!.length <= index) {
                                      if (state.browseStores!.length == index) {
                                        context.read<SmDiscoverBloc>().add(
                                          BrowseStoresEvent(
                                            isReload: false,
                                            params: BrowseStoresParams(
                                              page: state
                                                  .browseStores!
                                                  .pageNumber,
                                            ),
                                          ),
                                        );
                                      }
                                      return DownloadMore();
                                    }
                                    return StoreCard(
                                      store: state.browseStores![index],
                                    );
                                  },
                                  itemCount: state.browseStores!.listLength(1),
                                );
                              },
                              failedWidget: Center(
                                child: FailureWidget(
                                  message: state.errorMessage.toString(),
                                  onRetry: () {},
                                ),
                              ),
                              onTapRetry: () {},
                            );
                          },
                        ),
                ),
              ],
            ),
          )
        else
          Builder(
            builder: (context) {
              return Column(
                children: [
                  SizedBox(height: 24),
                  SearchesGroup(
                    title: "الأكثر بحثاً من قبل المستخدمين",
                    searches: [
                      "لبن المراعي",
                      "أندومي",
                      "حليب مكثف",
                      "حليب هوى الشام",
                      "طحين كاتو",
                      "رز كبسة",
                    ],
                    onSearchTap: (search) {
                      print(search);
                      makeSearch(context, search);
                    },
                  ),
                  SizedBox(height: 16),
                  Divider(height: 1, color: Color(0xFFDBDCDE)),
                  SizedBox(height: 16),
                  SearchesGroup(
                    title: "سجل البحث",
                    searches: searchHistory,
                    onSearchTap: (search) {
                      print(search);
                      makeSearch(context, search);
                    },
                    onDeleteAllTap: () async {
                      if (searchHistory.isEmpty) return;
                      searchHistory = [];
                      await SharedPreferencesHelper.removeData(
                        key: Constants.searchKey,
                      );
                      if (context.mounted) setState(() {});
                    },
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  @override
  void didUpdateWidget(covariant SmSearchView oldWidget) {
    if (isSearching == true && !isListening) {
      searchController.clear();
      isSearching = false;
      setState(() {});
    }
    final next = widget.initialSearch?.trim();
    final prev = oldWidget.initialSearch?.trim();
    if (next != null && next.isNotEmpty && next != prev) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        makeSearch(context, next);
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    speechToText.stop();
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchHistory =
        SharedPreferencesHelper.sharedPreferences!.getStringList(
          Constants.searchKey,
        ) ??
        [];
    speechToText = SpeechToText();
    final initial = widget.initialSearch?.trim();
    if (initial != null && initial.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        makeSearch(context, initial);
      });
    }
  }

  void makeSearch(BuildContext context, String search) {
    if (isSearching && search.isEmpty) {
      isSearching = false;
    } else if (!isSearching && search.isNotEmpty) {
      isSearching = true;
    }
    if (isSearching) {
      context.read<SmDiscoverBloc>().add(
        widget.type == SearchType.product
            ? BrowseProductsEvent(
                isReload: true,
                params: BrowseProductsParams(search: search),
              )
            : BrowseStoresEvent(
                isReload: true,
                params: BrowseStoresParams(search: search),
              ),
      );
    }
    searchController.text = search;
    setState(() {});
  }

  Future<void> _ensureSpeechInitialized() async {
    if (_speechInitialized) return;
    final available = await speechToText.initialize(
      onStatus: _onSpeechStatus,
      onError: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم التقاط أي صوت، يرجى التحدث بوضوح.'),
          ),
        );
      },
    );
    if (!available) {
      return;
    }
    _speechInitialized = true;
  }

  void _onSpeechStatus(String pluginStatus) {
    if (pluginStatus != SpeechToText.doneStatus &&
        pluginStatus != SpeechToText.notListeningStatus) {
      return;
    }
    if (!mounted) return;
    setState(() {
      isListening = false;
    });
  }

  Future<String?> _pickSpeechLocale() async {
    final locales = await speechToText.locales();
    for (final locale in locales) {
      if (locale.localeId.toLowerCase().startsWith('ar')) {
        return locale.localeId;
      }
    }
    final system = await speechToText.systemLocale();
    // return system?.localeId ?? "ar_SA";
    return "ar_SA";
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text(
            "إذن الميكروفون مطلوب",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "يجب تفعيل إذن الميكروفون للتمكن من التسجيل الصوتي.",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              child: const Text(
                "فتح الإعدادات",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startListening(BuildContext context) async {
    var status = await Permission.microphone.status;
    if (status.isPermanentlyDenied) {
      _showPermissionDialog();
      return;
    }
    if (status.isDenied || status.isRestricted) {
      status = await Permission.microphone.request();
    }
    if (!status.isGranted) {
      _showPermissionDialog();
      return;
    }

    await _ensureSpeechInitialized();
    if (!_speechInitialized) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الميكروفون أو التعرف الصوتي غير متاح')),
      );
      return;
    }

    final localeId = await _pickSpeechLocale();

    if (!context.mounted) return;
    voiceCancelledByUser = false;
    setState(() {
      searchController.clear();
      isListening = true;
    });

    if (localeId == null || !mounted) {
      setState(() => isListening = false);
      return;
    }
    if (speechToText.isListening) return;

    try {
      await speechToText.listen(
        onResult: (result) {
          if (!mounted) return;
          final text = result.recognizedWords;
          setState(() {
            searchController.text = text;
            searchController.selection = TextSelection.collapsed(
              offset: text.length,
            );
          });
          if (result.finalResult && !voiceCancelledByUser) {
            makeSearch(context, text);
          }
        },
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.confirmation,
          partialResults: true,
          cancelOnError: false,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      setState(() {
        isListening = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر بدء الاستماع. حاول مرة أخرى.')),
      );
    }
  }

  Future<void> _stopListening(BuildContext context) async {
    voiceCancelledByUser = true;
    await speechToText.stop();
    if (!context.mounted) return;
    setState(() {
      isListening = false;
    });
  }
}
