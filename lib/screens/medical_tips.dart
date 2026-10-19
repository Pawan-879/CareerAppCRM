import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Tips App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
      ),
      home: const MedicalTipsPage(),
    );
  }
}

class MedicalTipsPage extends StatefulWidget {
  static const String routeName = "/medical-tips";  // Add this line

  const MedicalTipsPage({Key? key}) : super(key: key);

  @override
  State<MedicalTipsPage> createState() => _MedicalTipsPageState();
}

class _MedicalTipsPageState extends State<MedicalTipsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEnglish = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medical Tips", style: TextStyle(fontWeight: FontWeight.bold,  color: Colors.white,)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        actions: [
         Switch(
  value: _isEnglish,
  activeThumbColor: Colors.white,
  onChanged: (value) {
    setState(() {
      _isEnglish = value;
    });
  },
  thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
    (Set<WidgetState> states) {
      return const Icon(Icons.language, color: Colors.blue);
    },
  ),
  activeTrackColor: Colors.blue.shade300,
  inactiveTrackColor: Colors.blue.shade300,
),

          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                _isEnglish ? "EN" : "हिंदी",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
       bottom: TabBar(
  controller: _tabController,
  isScrollable: true,
  indicatorColor: Colors.white,
  labelColor: Colors.white, // Active tab text color
  unselectedLabelColor: Colors.white70, // Inactive tab text color
  tabs: const [
    Tab(text: "Respiratory"),
    Tab(text: "Digestive"),
    Tab(text: "Nutritional"),
    Tab(text: "Allergies"),
    Tab(text: "Infections"),
  ],
),

      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMedicalTipCard(0),
          _buildMedicalTipCard(1),
          _buildMedicalTipCard(2),
          _buildMedicalTipCard(3),
          _buildMedicalTipCard(4),
        ],
      ),
    );
  }

  Widget _buildMedicalTipCard(int index) {
    final tip = medicalTips[index];
    final title = _isEnglish ? tip["title"] : tip["title_hindi"];
    final causes = _isEnglish ? tip["causes"] : tip["causes_hindi"];
    final preventiveMeasures = _isEnglish ? tip["preventive_measures"] : tip["preventive_measures_hindi"];
    final medicines = _isEnglish ? tip["medicines"] : tip["medicines_hindi"];
    final videoLinks = tip["video_links"] as List<String>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconForIndex(index),
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    _isEnglish ? "Common Medicines:" : "सामान्य दवाएं:",
                    medicines!,
                    Icons.medication,
                    Colors.red.shade700,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    _isEnglish ? "Causes:" : "कारण:",
                    causes!,
                    Icons.warning_rounded,
                    Colors.orange.shade700,
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    _isEnglish ? "Preventive Measures:" : "रोकथाम के उपाय:",
                    preventiveMeasures!,
                    Icons.check_circle,
                    Colors.green.shade700,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.video_library, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _isEnglish ? "Related Videos:" : "संबंधित वीडियो:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: videoLinks.length,
                          itemBuilder: (context, videoIndex) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: InkWell(
                                onTap: () => _launchURL(videoLinks[videoIndex]),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 140,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.red.shade700, width: 2),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.play_circle_fill,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isEnglish ? "Video ${videoIndex + 1}" : "वीडियो ${videoIndex + 1}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.air;
      case 1:
        return Icons.restaurant;
      case 2:
        return Icons.fitness_center;
      case 3:
        return Icons.healing;
      case 4:
        return Icons.coronavirus;
      default:
        return Icons.medical_services;
    }
  }

  final List<Map<String, dynamic>> medicalTips = [
    {
      "title": "1️⃣ Respiratory Issues (Cough, Cold, Flu)",
      "title_hindi": "1️⃣ श्वसन संबंधी समस्याएं (खांसी, जुकाम, फ्लू)",
      "medicines": "Common Medicines: Cough Syrup, Kuff Plus, Chestencold Tab",
      "medicines_hindi": "सामान्य दवाएं: कफ सिरप, कफ प्लस, चेस्टेनकोल्ड टैब",
      "causes": "🔹 Viral infections due to close contact in hostels and classrooms\n🔹 Poor ventilation and air quality\n🔹 Seasonal changes and temperature fluctuations",
      "causes_hindi": "🔹 छात्रावास और कक्षा में नजदीकी संपर्क के कारण वायरल संक्रमण\n🔹 खराब वेंटिलेशन और वायु गुणवत्ता\n🔹 मौसमी परिवर्तन और तापमान में उतार-चढ़ाव",
      "preventive_measures": "✔ Ensure well-ventilated classrooms with proper air circulation\n✔ Conduct regular cleaning and sanitization of shared spaces\n✔ Encourage students to use handkerchiefs or tissues while coughing or sneezing\n✔ Maintain personal hygiene (e.g., frequent hand washing)\n✔ Provide immunity-boosting drinks like warm turmeric milk or herbal tea during seasonal changes\n✔ Organize health awareness programs to teach students about preventing colds and flu",
      "preventive_measures_hindi": "✔ कक्षाओं को हवादार और अच्छी वायु परिसंचरण युक्त बनाए रखें\n✔ साझा स्थानों की नियमित सफाई और सैनीटाइजेशन सुनिश्चित करें\n✔ छात्रों को खांसते या छींकते समय रूमाल या टिशू का उपयोग करने के लिए प्रोत्साहित करें\n✔ व्यक्तिगत स्वच्छता बनाए रखें (जैसे, बार-बार हाथ धोना)\n✔ प्रतिरक्षा बढ़ाने वाले पेय पदार्थ जैसे हल्दी वाला गर्म दूध या हर्बल चाय प्रदान करें\n✔ छात्रों को जुकाम और फ्लू से बचाव के उपाय सिखाने के लिए स्वास्थ्य जागरूकता कार्यक्रम आयोजित करें",
      "video_links": [
        "https://www.youtube.com/watch?v=WK3MiOX5C08",
        "https://www.youtube.com/watch?v=0XOWOY3rZ0k",
        "https://www.youtube.com/watch?v=BVfnMCamGYM&t=68s"
      ]
    },
    {
      "title": "2️⃣ Digestive Problems (Acidity, Indigestion)",
      "title_hindi": "2️⃣ पाचन संबंधी समस्याएं (अम्लता, अपच)",
      "medicines": "Common Medicines: Aciloc Tab, Aciloc-Tab",
      "medicines_hindi": "सामान्य दवाएं: एसिलोक टैब",
      "causes": "🔹 Irregular eating habits\n🔹 Consumption of oily/spicy foods\n🔹 Stress or anxiety before exams",
      "causes_hindi": "🔹 अनियमित खान-पान की आदतें\n🔹 अधिक तली-भुनी और मसालेदार चीजों का सेवन\n🔹 परीक्षा से पहले तनाव या चिंता",
      "preventive_measures": "✔ Maintain a balanced diet in hostel and school canteens\n✔ Ensure students follow regular meal timings\n✔ Introduce healthy snacks like fruits, nuts, and yogurt\n✔ Promote hydration by ensuring clean drinking water is readily available\n✔ Encourage students to eat slowly and mindfully",
      "preventive_measures_hindi": "✔ छात्रावास और स्कूल की कैंटीन में संतुलित आहार सुनिश्चित करें\n✔ छात्रों को नियमित भोजन करने के लिए प्रेरित करें\n✔ स्वस्थ नाश्ते जैसे फल, नट्स और दही की उपलब्धता सुनिश्चित करें\n✔ स्वच्छ पेयजल की उचित व्यवस्था करें\n✔ छात्रों को धीरे-धीरे और सावधानीपूर्वक खाने के लिए प्रेरित करें",
      "video_links": [
        "https://www.youtube.com/watch?v=OmvardkwIAw",
        "https://www.youtube.com/watch?v=13tAqk9VQvU",
        "https://www.youtube.com/watch?v=joQxnFpDIPE"
      ]
    },
    {
      "title": "3️⃣ Nutritional Deficiencies (Fatigue, Weakness)",
      "title_hindi": "3️⃣ पोषण की कमी (थकान, कमजोरी)",
      "medicines": "Common Medicines: TAB. Multivitamin",
      "medicines_hindi": "सामान्य दवाएं: मल्टीविटामिन टैबलेट",
      "causes": "🔹 Poor dietary intake\n🔹 Lack of fruits, vegetables, and essential nutrients\n🔹 Excessive junk food consumption",
      "causes_hindi": "🔹 अपर्याप्त आहार\n🔹 फलों, सब्जियों और आवश्यक पोषक तत्वों की कमी\n🔹 अत्यधिक जंक फूड का सेवन",
      "preventive_measures": "✔ Design a nutrient-rich menu with balanced portions of protein, carbs, and vitamins\n✔ Organize nutrition awareness programs for students and parents\n✔ Offer healthy snacks like fruit bowls, sprouts, and dry fruits in hostels\n✔ Encourage participation in physical activities to improve metabolism and energy levels",
      "preventive_measures_hindi": "✔ प्रोटीन, कार्बोहाइड्रेट और विटामिन से भरपूर संतुलित आहार योजना तैयार करें\n✔ छात्रों और अभिभावकों के लिए पोषण जागरूकता कार्यक्रम आयोजित करें\n✔ छात्रावास में स्वस्थ नाश्ते जैसे फल, स्प्राउट्स और सूखे मेवे उपलब्ध कराएं\n✔ छात्रों को खेलकूद और शारीरिक गतिविधियों में भाग लेने के लिए प्रेरित करें ताकि चयापचय (मेटाबॉलिज्म) बेहतर बना रहे",
      "video_links": [
        "https://www.youtube.com/watch?v=F67xAbembAA",
        "https://www.youtube.com/watch?v=dliMsyfmYp4",
        "https://www.youtube.com/watch?v=cPg7UYLUxWA"
      ]
    },
    {
      "title": "4️⃣ Allergies (Skin Allergy, Throat Pain)",
      "title_hindi": "4️⃣ एलर्जी (त्वचा एलर्जी, गले में दर्द)",
      "medicines": "Common Medicines: Levocetzy Tab, Monteral LC Tab",
      "medicines_hindi": "सामान्य दवाएं: लेवोसेटज़ी टैब, मोंटेरल एलसी टैब",
      "causes": "🔹 Dust, pollen, or environmental allergens\n🔹 Use of unclean bedding, curtains, or carpets\n🔹 Skin irritation from chemical products",
      "causes_hindi": "🔹 धूल, पराग या पर्यावरणीय एलर्जी\n🔹 गंदे बिस्तर, पर्दे या कालीनों का उपयोग\n🔹 रासायनिक उत्पादों से त्वचा में जलन",
      "preventive_measures": "✔ Conduct regular dusting and cleaning of dormitories and classrooms\n✔ Ensure bedding, mattresses, and curtains are washed frequently\n✔ Introduce air purifiers in classrooms and dormitories if feasible\n✔ Educate students to avoid sharing personal hygiene items like towels and combs",
      "preventive_measures_hindi": "✔ छात्रावास और कक्षाओं की नियमित धूल सफाई और सफाई सुनिश्चित करें\n✔ बिस्तर, गद्दे और पर्दों की नियमित धुलाई की व्यवस्था करें\n✔ यदि संभव हो तो कक्षाओं और छात्रावासों में एयर प्यूरीफायर लगवाएं\n✔ छात्रों को व्यक्तिगत स्वच्छता बनाए रखने और तौलिए, कंघी आदि साझा न करने की सलाह दें",
      "video_links": [
        "https://www.youtube.com/watch?v=GTJ4WWB3v1A",
        "https://www.youtube.com/watch?v=qiWiYfqeDjg",
        "https://www.youtube.com/watch?v=1PO1IbW9ojY"
      ]
    },
    {
      "title": "5️⃣ Bacterial Infections (Fever, Throat Infections, Skin Infections)",
      "title_hindi": "5️⃣ बैक्टीरियल संक्रमण (बुखार, गले का संक्रमण, त्वचा संक्रमण)",
      "medicines": "Common Medicines: Amoxy CV Tab, Zifi Tab",
      "medicines_hindi": "सामान्य दवाएं: एमॉक्सी सीवी टैब, ज़िफी टैब",
      "causes": "🔹 Close contact in hostel environments\n🔹 Poor personal hygiene\n🔹 Sharing of personal belongings",
      "causes_hindi": "🔹 छात्रावास में नजदीकी संपर्क\n🔹 व्यक्तिगत स्वच्छता की कमी\n🔹 व्यक्तिगत वस्तुओं को साझा करना",
      "preventive_measures": "✔ Introduce weekly health check-ups to identify symptoms early\n✔ Promote proper hand hygiene with regular handwashing reminders\n✔ Educate students about not sharing personal items like water bottles, towels, or razors\n✔ Ensure proper wound care facilities are available in the medical room",
      "preventive_measures_hindi": "✔ प्रारंभिक लक्षणों की पहचान के लिए साप्ताहिक स्वास्थ्य जांच करें\n✔ नियमित रूप से हाथ धोने की आदत को बढ़ावा दें\n✔ छात्रों को व्यक्तिगत वस्तुओं जैसे पानी की बोतल, तौलिया या रेजर साझा न करने के बारे में शिक्षित करें\n✔ चिकित्सा कक्ष में उचित घाव देखभाल सुविधाएं उपलब्ध कराएं",
      "video_links": [
        "https://www.youtube.com/watch?v=KUcOlfjMjGc",
        "https://www.youtube.com/watch?v=9lyzdPe8jgU",
        "https://www.youtube.com/watch?v=-aIvWxfpCco"
      ]
    },
  ];
}

