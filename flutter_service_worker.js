'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/chromium/canvaskit.js": "ba4a8ae1a65ff3ad81c6818fd47e348b",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/canvaskit.js": "6cfe36b4647fbfa15683e09e7dd366bc",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "86f89640b374e0a090515d6d04e7879d",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "4769f3245a24c1fa9965f113ea85ec2a",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "3ca5dc7621921b901d513cc1ce23788c",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "cccd7a52744c6899d41c0faf0c51be2f",
"assets/AssetManifest.bin": "a2757c8fc8f334f55c15722d36fb4899",
"assets/fonts/MaterialIcons-Regular.otf": "8c6231c0259e1bf2772c18f2b69dd2e5",
"assets/AssetManifest.json": "4a8e4e7877c107e894805dc465afb4db",
"assets/FontManifest.json": "5a32d4310a6f5d9a6b651e75ba0d7372",
"assets/assets/lottie/page_under_construction.json": "2d361eaa7dd473983c52ee2bffe395f4",
"assets/assets/fonts/gilroy/Gilroy-Regular.ttf": "31ff7c1a62a300dbbf9656b4ba14a0d5",
"assets/assets/fonts/gilroy/Gilroy-RegularItalic.ttf": "b564aec808c412ff20b83a2d779122b5",
"assets/assets/image/football.png": "03c20dbb9f1c9bc86cc8f9b8ac9db676",
"assets/assets/image/logo.png": "7b9f4c085d20457b60057ded178fa387",
"assets/assets/image/black.png": "7eae69a00ea33b681015ec05cb369352",
"assets/assets/image/line.png": "f46d529b232d86a289f0609c06b75f9d",
"assets/assets/image/soccer-field.png": "9f9a100426b7559cb433f423a1312845",
"assets/assets/image/splash.svg": "b66256c40bcc39f09d7a557b3b67c9d0",
"assets/assets/images/medal.png": "293c5e6870f518c4f940eb809c1e87ac",
"assets/assets/images/smartphone.png": "457bd3ba8e856b521d15ef3f1aa6bd1c",
"assets/assets/images/traffic-cone.png": "b7b2c7cdcca53e9fa98b0cc3350c0db6",
"assets/assets/images/goal-post.png": "83181686a8ac9a5068948b2c1969081e",
"assets/assets/images/whistle.png": "427c9ff13b7c8681c7d7cbd67798cf12",
"assets/assets/images/referee-jersey.png": "7b22442182f62b233443398d037e33d5",
"assets/assets/images/podium.png": "5022f6c92bdff78e13ff1bccbcb4f5f3",
"assets/assets/images/block.png": "24df912687a35ced57ba891f2f2e46dd",
"assets/assets/images/dummy.png": "730167144541998db6f820925c3349c6",
"assets/assets/images/logo.png": "7b9f4c085d20457b60057ded178fa387",
"assets/assets/images/diagonal-line-right-turn.png": "94dccfc82c8ca3ec6917658717cd4754",
"assets/assets/images/text.png": "bdd738b30dfcaca4d520ea98a9e1cbe6",
"assets/assets/images/diagonal-line-dashed.png": "a29b86020672ffdba17304382b1d4575",
"assets/assets/images/half-circle.png": "5052abb2bd92695d814fd515bc1819d0",
"assets/assets/images/circle.png": "90482ab080d61e660ead8bc8ca9074ce",
"assets/assets/images/diagonal-line-zigzag-arrow.png": "362563239804ff2fa215e3d3c5fba89a",
"assets/assets/images/dumbbell.png": "0d8f890c3c33e9b832060350c85c5976",
"assets/assets/images/polygon.png": "f4d69bff1f370d1d019485d9d2ef4d91",
"assets/assets/images/square.png": "45beda6014130becc3db1c58210124ee",
"assets/assets/images/cone.png": "cde83d51e749bd39f4847293499128a2",
"assets/assets/images/world-cup.png": "5ff4a15c99a7bad9eb1cf4f99d6dd1f7",
"assets/assets/images/ball.png": "16ebe3678059f26eb8c59584324ae059",
"assets/assets/images/diagonal-line-arrow-double.png": "db8c1e760701b85c10571df36d8e633e",
"assets/assets/images/diagonal-line.png": "f46d529b232d86a289f0609c06b75f9d",
"assets/assets/images/diagonal-line-zigzag.png": "8072e385fb5dcc60deb898fa39e0159a",
"assets/assets/images/free-draw.png": "f5df7bced70a7284f63dbd7b45e8654c",
"assets/assets/images/stopwatch.png": "51c8e4bd6038dd9e2f02b7fd393e9ff0",
"assets/assets/images/net.png": "86fe04f397f900a8b35ab126baa90893",
"assets/assets/images/bullseye.png": "71311d128f5363101b22f8fd642f66af",
"assets/assets/images/digital-clock.png": "997645e1942e7c3e84e44656d391d33e",
"assets/assets/images/pole-dance.png": "456bc96aeddf523d8bbcf2bbc612ad4f",
"assets/assets/images/ladder.png": "bae5ac694150852357cd6e610fa27b0e",
"assets/assets/images/triangle.png": "1e96073c46f9fefde632c39f1ffd6b84",
"assets/assets/images/scoreboard.png": "e42eb6146297c197acf6f328194eb657",
"assets/assets/images/diagonal-line-arrow.png": "768f74642ecae2d6539120a121ffb6bb",
"assets/NOTICES": "e33624931939a0a9fbc8b60d0a406a0f",
"assets/AssetManifest.bin.json": "491c0557213c246054659c4aaf8c77dd",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"manifest.json": "e4803bafd6a2cacaf2eaae2d5d9004f2",
"index.html": "42dc98adf389fa811bcea4d5fbd972df",
"/": "42dc98adf389fa811bcea4d5fbd972df",
"version.json": "6e7249480dd1bb3238d47bb267e4231a",
"flutter_bootstrap.js": "4cd93a155b34e3f220b5882ed82c5029",
"main.dart.js": "3c8be263a2a0845189dccbb14ce036ce",
"favicon.png": "5dcef449791fa27946b3d35ad8803796"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
