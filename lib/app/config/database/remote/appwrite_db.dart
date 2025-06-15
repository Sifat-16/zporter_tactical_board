// file: core/services/appwrite_client_factory.dart

import 'package:appwrite/appwrite.dart';

/// A factory class responsible for creating a configured Appwrite client.
/// This encapsulates the setup logic in one place.
class AppwriteClientFactory {
  // --- IMPORTANT: Replace with your Appwrite project details ---
  String appwriteEndpoint =
      "https://fra.cloud.appwrite.io/v1"; // Or your self-hosted endpoint
  String appwriteProjectId = "684dfad7001cdada7134";

  /// Creates and configures a new Appwrite [Client] instance.
  Client create() {
    final client = Client();
    client
        .setEndpoint(appwriteEndpoint)
        .setProject(appwriteProjectId)
        // Use this only in development with a self-signed SSL certificate
        .setSelfSigned(status: true);
    return client;
  }
}
