Swrve SDK Cordova Plugin
========================

What is Swrve
-------------
Swrve is a single integrated platform delivering everything you need to drive mobile engagement and create valuable consumer relationships on mobile.  
This PhoneGap plugin will enable your app to use all of these features on Android and iOS.

Getting started
---------------
Have a look at the quick integration guide at http://docs.swrve.com/developer-documentation/37926233/

Testing
-------
Run the rake task 'rake build'. This will update the demo project with the latest source from the Swrve plugin and compile both Android and iOS platforms.


Both platform targets have native tests that are able to test the wrapper code. There are also two rake tasks that you can run:

```testIOSInSimulator["OS=8.3\,name='iPad Air'"]```

```testAndroidInEmulator["2.3.3"]```

Contributing
------------
We would love to see your contributions! Follow these steps:

1. Fork this repository.
2. Create a branch (`git checkout -b my_awesome_phonegap_feature`)
3. Commit your changes (`git commit -m "Awesome PhoneGap feature"`)
4. Push to the branch (`git push origin my_awesome_phonegap_feature`)
5. Open a Pull Request.

License
-------
© Copyright Swrve Mobile Inc or its licensors. Distributed under the [Apache 2.0 License](LICENSE).
