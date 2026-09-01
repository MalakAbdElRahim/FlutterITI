import 'package:flutter/material.dart';



class MovieCard extends StatelessWidget {
  

  const MovieCard({
    super.key, 

  });

  @override
  Widget build(BuildContext context) {
    return  Card(
      color: Theme.of(context).colorScheme.tertiary,
      margin: EdgeInsets.all(12),
      
      
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: 
        Expanded(
          child: Container(
            child: Row(),
          ),
        )
      
      ),
    );
  }
}