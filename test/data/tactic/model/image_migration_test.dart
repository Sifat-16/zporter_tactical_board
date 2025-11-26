import 'package:flutter_test/flutter_test.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:flame/components.dart';

void main() {
  group('PlayerModel Image Migration', () {
    test('should have imageUrl field in model', () {
      final player = PlayerModel(
        id: 'test-player',
        offset: Vector2.zero(),
        role: 'Forward',
        jerseyNumber: 10,
        playerType: PlayerType.HOME,
        imageUrl: 'https://firebasestorage.googleapis.com/test.jpg',
      );

      expect(
          player.imageUrl, 'https://firebasestorage.googleapis.com/test.jpg');
    });

    test('should detect base64 image', () {
      final player = PlayerModel(
        id: 'test-player',
        offset: Vector2.zero(),
        role: 'Forward',
        jerseyNumber: 10,
        playerType: PlayerType.HOME,
        imageBase64: 'data:image/jpeg;base64,/9j/4AAQSkZJRg==',
      );

      expect(player.hasBase64Image, isTrue);
      expect(player.hasImageUrl, isFalse);
    });

    test('should detect imageUrl', () {
      final player = PlayerModel(
        id: 'test-player',
        offset: Vector2.zero(),
        role: 'Forward',
        jerseyNumber: 10,
        playerType: PlayerType.HOME,
        imageUrl: 'https://firebasestorage.googleapis.com/test.jpg',
      );

      expect(player.hasBase64Image, isFalse);
      expect(player.hasImageUrl, isTrue);
    });

    test('should detect need for migration', () {
      final playerNeedsMigration = PlayerModel(
        id: 'test-player-1',
        offset: Vector2.zero(),
        role: 'Forward',
        jerseyNumber: 10,
        playerType: PlayerType.HOME,
        imageBase64: 'data:image/jpeg;base64,/9j/4AAQSkZJRg==',
      );

      expect(playerNeedsMigration.needsImageMigration, isTrue);

      final playerAlreadyMigrated = PlayerModel(
        id: 'test-player-2',
        offset: Vector2.zero(),
        role: 'Forward',
        jerseyNumber: 11,
        playerType: PlayerType.HOME,
        imageBase64: 'data:image/jpeg;base64,/9j/4AAQSkZJRg==',
        imageUrl: 'https://firebasestorage.googleapis.com/test.jpg',
      );

      expect(playerAlreadyMigrated.needsImageMigration, isFalse);

      final playerNoImage = PlayerModel(
        id: 'test-player-3',
        offset: Vector2.zero(),
        role: 'Forward',
        jerseyNumber: 12,
        playerType: PlayerType.HOME,
      );

      expect(playerNoImage.needsImageMigration, isFalse);
    });

    test('should serialize imageUrl to JSON', () {
      final player = PlayerModel(
        id: 'test-player',
        offset: Vector2.zero(),
        role: 'Forward',
        jerseyNumber: 10,
        playerType: PlayerType.HOME,
        imageUrl: 'https://firebasestorage.googleapis.com/test.jpg',
        imageBase64: 'data:image/jpeg;base64,/9j/4AAQSkZJRg==',
      );

      final json = player.toJson();

      expect(
          json['imageUrl'], 'https://firebasestorage.googleapis.com/test.jpg');
      expect(json['imageBase64'], 'data:image/jpeg;base64,/9j/4AAQSkZJRg==');
    });

    test('should deserialize imageUrl from JSON', () {
      final json = {
        '_id': 'test-player',
        'offset': {'x': 0.0, 'y': 0.0},
        'role': 'Forward',
        'jerseyNumber': 10,
        'playerType': 'HOME',
        'imageUrl': 'https://firebasestorage.googleapis.com/test.jpg',
        'imageBase64': 'data:image/jpeg;base64,/9j/4AAQSkZJRg==',
      };

      final player = PlayerModel.fromJson(json);

      expect(
          player.imageUrl, 'https://firebasestorage.googleapis.com/test.jpg');
      expect(player.imageBase64, 'data:image/jpeg;base64,/9j/4AAQSkZJRg==');
    });

    test('should handle missing imageUrl in old JSON', () {
      final json = {
        '_id': 'test-player',
        'offset': {'x': 0.0, 'y': 0.0},
        'role': 'Forward',
        'jerseyNumber': 10,
        'playerType': 'HOME',
        'imageBase64': 'data:image/jpeg;base64,/9j/4AAQSkZJRg==',
      };

      final player = PlayerModel.fromJson(json);

      expect(player.imageUrl, isNull);
      expect(player.imageBase64, 'data:image/jpeg;base64,/9j/4AAQSkZJRg==');
      expect(player.needsImageMigration, isTrue);
    });

    test('should copy with new imageUrl', () {
      final player = PlayerModel(
        id: 'test-player',
        offset: Vector2.zero(),
        role: 'Forward',
        jerseyNumber: 10,
        playerType: PlayerType.HOME,
        imageBase64: 'data:image/jpeg;base64,/9j/4AAQSkZJRg==',
      );

      final migrated = player.copyWith(
        imageUrl: 'https://firebasestorage.googleapis.com/test.jpg',
      );

      expect(
          migrated.imageUrl, 'https://firebasestorage.googleapis.com/test.jpg');
      expect(migrated.imageBase64, 'data:image/jpeg;base64,/9j/4AAQSkZJRg==');
      expect(migrated.needsImageMigration, isFalse);
    });

    test('should handle empty string as no image', () {
      final player = PlayerModel(
        id: 'test-player',
        offset: Vector2.zero(),
        role: 'Forward',
        jerseyNumber: 10,
        playerType: PlayerType.HOME,
        imageBase64: '',
        imageUrl: '',
      );

      expect(player.hasBase64Image, isFalse);
      expect(player.hasImageUrl, isFalse);
      expect(player.needsImageMigration, isFalse);
    });
  });

  group('EquipmentModel Image Migration', () {
    test('should have imageUrl field in model', () {
      final equipment = EquipmentModel(
        id: 'test-equipment',
        offset: Vector2.zero(),
        name: 'Ball',
        imageUrl: 'https://firebasestorage.googleapis.com/ball.jpg',
      );

      expect(equipment.imageUrl,
          'https://firebasestorage.googleapis.com/ball.jpg');
    });

    test('should detect imagePath', () {
      final equipment = EquipmentModel(
        id: 'test-equipment',
        offset: Vector2.zero(),
        name: 'Ball',
        imagePath: 'assets/images/ball.png',
      );

      expect(equipment.hasImagePath, isTrue);
      expect(equipment.hasImageUrl, isFalse);
    });

    test('should detect imageUrl', () {
      final equipment = EquipmentModel(
        id: 'test-equipment',
        offset: Vector2.zero(),
        name: 'Ball',
        imageUrl: 'https://firebasestorage.googleapis.com/ball.jpg',
      );

      expect(equipment.hasImagePath, isFalse);
      expect(equipment.hasImageUrl, isTrue);
    });

    test('should detect need for migration', () {
      final equipmentNeedsMigration = EquipmentModel(
        id: 'test-equipment-1',
        offset: Vector2.zero(),
        name: 'Ball',
        imagePath: 'assets/images/ball.png',
      );

      expect(equipmentNeedsMigration.needsImageMigration, isTrue);

      final equipmentAlreadyMigrated = EquipmentModel(
        id: 'test-equipment-2',
        offset: Vector2.zero(),
        name: 'Ball',
        imagePath: 'assets/images/ball.png',
        imageUrl: 'https://firebasestorage.googleapis.com/ball.jpg',
      );

      expect(equipmentAlreadyMigrated.needsImageMigration, isFalse);

      final equipmentNoImage = EquipmentModel(
        id: 'test-equipment-3',
        offset: Vector2.zero(),
        name: 'Ball',
      );

      expect(equipmentNoImage.needsImageMigration, isFalse);
    });

    test('should serialize imageUrl to JSON', () {
      final equipment = EquipmentModel(
        id: 'test-equipment',
        offset: Vector2.zero(),
        name: 'Ball',
        imageUrl: 'https://firebasestorage.googleapis.com/ball.jpg',
        imagePath: 'assets/images/ball.png',
      );

      final json = equipment.toJson();

      expect(
          json['imageUrl'], 'https://firebasestorage.googleapis.com/ball.jpg');
      expect(json['imagePath'], 'assets/images/ball.png');
    });

    test('should deserialize imageUrl from JSON', () {
      final json = {
        '_id': 'test-equipment',
        'offset': {'x': 0.0, 'y': 0.0},
        'name': 'Ball',
        'imageUrl': 'https://firebasestorage.googleapis.com/ball.jpg',
        'imagePath': 'assets/images/ball.png',
      };

      final equipment = EquipmentModel.fromJson(json);

      expect(equipment.imageUrl,
          'https://firebasestorage.googleapis.com/ball.jpg');
      expect(equipment.imagePath, 'assets/images/ball.png');
    });

    test('should handle missing imageUrl in old JSON', () {
      final json = {
        '_id': 'test-equipment',
        'offset': {'x': 0.0, 'y': 0.0},
        'name': 'Ball',
        'imagePath': 'assets/images/ball.png',
      };

      final equipment = EquipmentModel.fromJson(json);

      expect(equipment.imageUrl, isNull);
      expect(equipment.imagePath, 'assets/images/ball.png');
      expect(equipment.needsImageMigration, isTrue);
    });

    test('should copy with new imageUrl', () {
      final equipment = EquipmentModel(
        id: 'test-equipment',
        offset: Vector2.zero(),
        name: 'Ball',
        imagePath: 'assets/images/ball.png',
      );

      final migrated = equipment.copyWith(
        imageUrl: 'https://firebasestorage.googleapis.com/ball.jpg',
      );

      expect(
          migrated.imageUrl, 'https://firebasestorage.googleapis.com/ball.jpg');
      expect(migrated.imagePath, 'assets/images/ball.png');
      expect(migrated.needsImageMigration, isFalse);
    });

    test('should handle empty string as no image', () {
      final equipment = EquipmentModel(
        id: 'test-equipment',
        offset: Vector2.zero(),
        name: 'Ball',
        imagePath: '',
        imageUrl: '',
      );

      expect(equipment.hasImagePath, isFalse);
      expect(equipment.hasImageUrl, isFalse);
      expect(equipment.needsImageMigration, isFalse);
    });
  });
}
