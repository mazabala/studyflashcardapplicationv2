# Data Format Documentation

This document describes the data formats used in the Deck Focus application.

## Flashcard Data Format

Flashcards are stored in JSON format with the following structure:

```json
{
  "decks": [
    {
      "topic": "String",
      "focus": "String",
      "category": "String",
      "difficultyLevel": "String",
      "cardCount": Number,
      "cards": [
        {
          "question": "String",
          "answer": "String",
          "tags": ["String", "String", ...],
          "difficulty": "String"
        }
      ]
    }
  ]
}
```

### Fields

- **topic**: The main subject area (e.g., "Cardiology", "Neurology")
- **focus**: The specific focus within the topic (e.g., "Heart Failure", "Stroke Management")
- **category**: The general category (e.g., "Medicine", "Computer Science")
- **difficultyLevel**: Overall difficulty of the deck ("Beginner", "Intermediate", "Advanced")
- **cardCount**: Number of cards in the deck
- **cards**: Array of flashcard objects
  - **question**: The front side of the flashcard
  - **answer**: The back side of the flashcard
  - **tags**: Array of tags for categorizing the card
  - **difficulty**: Individual card difficulty ("Easy", "Medium", "Hard")

## Example

See the example files in the `data/` directory:

- `example_deck_import.json`: Basic deck structure
- `example_deck_import_with_collection.json`: Deck with collection structure
- `cardiology_flashcards.json`: Complete cardiology flashcard deck
- `pharmacology_flashcards.json`: Complete pharmacology flashcard deck 