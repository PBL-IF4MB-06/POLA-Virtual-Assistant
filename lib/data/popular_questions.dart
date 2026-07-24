class PopularQuestion {
  const PopularQuestion({
    required this.question,
    required this.category,
    required this.askCount,
  });

  final String question;
  final String category;
  final int askCount;
}

class PopularQuestions {
  static const all = <PopularQuestion>[
    PopularQuestion(
      question: 'Kapan jadwal KRS semester ini?',
      category: 'Akademik',
      askCount: 128,
    ),
    PopularQuestion(
      question: 'Bagaimana prosedur cuti kuliah?',
      category: 'Akademik',
      askCount: 96,
    ),
    PopularQuestion(
      question: 'Di mana lokasi gedung TI?',
      category: 'Kampus',
      askCount: 84,
    ),
    PopularQuestion(
      question: 'Informasi beasiswa apa saja yang tersedia?',
      category: 'Beasiswa',
      askCount: 112,
    ),
    PopularQuestion(
      question: 'Bagaimana cara mengisi KRS di SIA?',
      category: 'Akademik',
      askCount: 77,
    ),
    PopularQuestion(
      question: 'Apa persyaratan PKL/magang?',
      category: 'Magang',
      askCount: 65,
    ),
    PopularQuestion(
      question: 'Jelaskan alur PBL di Polibatam.',
      category: 'Akademik',
      askCount: 58,
    ),
    PopularQuestion(
      question: 'Apa kontak bagian akademik kampus?',
      category: 'Bantuan',
      askCount: 43,
    ),
  ];
}
