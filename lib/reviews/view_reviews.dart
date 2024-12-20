import 'package:flutter/material.dart';

class ViewReviewsPage extends StatelessWidget {
  const ViewReviewsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for reviews
    final List<Map<String, dynamic>> reviews = [
      {
        'rating': 5,
        'comment': 'Really kind service, will definietly come back',
      },
      {
        'rating': 3,
        'comment': 'Good food, but small portion for the price',
      },
      {
        'rating': 4,
        'comment': 'The food was delicious, but the wait time was a bit long.',
      },
      {
        'rating': 5,
        'comment': 'Best restaurant in Denpasar! Highly recommend the burgers and fries.',
      },
      {
        'rating': 2,
        'comment': 'The ambiance was nice, but staff was unkind and bad service.',
      },
      {
        'rating': 4,
        'comment': 'Great for hangouts and appropriate for families!',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('View Reviews'),
        backgroundColor: const Color(0xFF5C2A3C), // Purple color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < review['rating']
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review['comment'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
