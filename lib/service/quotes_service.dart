import 'dart:math';

class QuotesService {
  static final List<Map<String, String>> _quotes = [
    {
      'quote':
          'Le succès n\'est pas final, l\'échec n\'est pas fatal : c\'est le courage de continuer qui compte.',
      'author': 'Winston Churchill',
    },
    {
      'quote':
          'La seule façon de faire du bon travail est d\'aimer ce que vous faites.',
      'author': 'Steve Jobs',
    },
    {
      'quote': 'Chaque accomplissement commence par la décision d\'essayer.',
      'author': 'John F. Kennedy',
    },
    {
      'quote':
          'Le futur appartient à ceux qui croient à la beauté de leurs rêves.',
      'author': 'Eleanor Roosevelt',
    },
    {
      'quote': 'Ne regardez pas l\'horloge ; faites comme elle, continuez.',
      'author': 'Sam Levenson',
    },
    {
      'quote':
          'La productivité n\'est jamais un accident. C\'est le résultat d\'un engagement envers l\'excellence.',
      'author': 'Paul J. Meyer',
    },
    {
      'quote':
          'Commencez là où vous êtes. Utilisez ce que vous avez. Faites ce que vous pouvez.',
      'author': 'Arthur Ashe',
    },
    {
      'quote': 'Le secret pour avancer est de commencer.',
      'author': 'Mark Twain',
    },
    {
      'quote':
          'Vous n\'avez pas à être génial pour commencer, mais vous devez commencer pour être génial.',
      'author': 'Zig Ziglar',
    },
    {
      'quote':
          'Une tâche à la fois, un jour à la fois. C\'est ainsi que l\'on avance.',
      'author': 'Anonyme',
    },
    {
      'quote': 'Le plus grand voyage commence par un simple pas.',
      'author': 'Lao Tseu',
    },
    {
      'quote': 'Croyez que vous pouvez et vous êtes à mi-chemin.',
      'author': 'Theodore Roosevelt',
    },
    {
      'quote': 'L\'action est la clé fondamentale de tout succès.',
      'author': 'Pablo Picasso',
    },
    {
      'quote':
          'Ce n\'est pas parce que les choses sont difficiles que nous n\'osons pas, c\'est parce que nous n\'osons pas qu\'elles sont difficiles.',
      'author': 'Sénèque',
    },
    {
      'quote': 'Chaque jour est une nouvelle chance de changer votre vie.',
      'author': 'Anonyme',
    },
    {
      'quote':
          'La discipline est le pont entre les objectifs et l\'accomplissement.',
      'author': 'Jim Rohn',
    },
    {
      'quote': 'Petit à petit, l\'oiseau fait son nid.',
      'author': 'Proverbe français',
    },
    {
      'quote':
          'Le meilleur moment pour planter un arbre était il y a 20 ans. Le deuxième meilleur moment est maintenant.',
      'author': 'Proverbe chinois',
    },
    {
      'quote':
          'Votre temps est limité, ne le gaspillez pas à vivre la vie de quelqu\'un d\'autre.',
      'author': 'Steve Jobs',
    },
    {
      'quote':
          'Les grandes choses ne sont jamais faites par une seule personne. Elles sont faites par une équipe.',
      'author': 'Steve Jobs',
    },
  ];

  static Map<String, String> getDailyQuote() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = dayOfYear % _quotes.length;
    return _quotes[index];
  }

  static Map<String, String> getRandomQuote() {
    final random = Random();
    return _quotes[random.nextInt(_quotes.length)];
  }

  static List<Map<String, String>> getAllQuotes() {
    return _quotes;
  }
}
