class onboardContent {
  String image;
  String title;
  String discription;

  onboardContent(
      {required this.image, required this.title, required this.discription});
}

List<onboardContent> contents = [
  onboardContent(
      image: 'assets/onboard/logo.png',
      title: 'Welcome to Basket Finder',
      discription: 'This app was created to help our community locate nearby garbage and recycling bins more easily.'
      ),
      onboardContent(
      image: 'assets/onboard/addloc.png',
      title: 'Adding Locaions',
      discription: 'You can help others by marking bins wherever you are.make sure the bin is there before adding.',
      ),
      onboardContent(
      image: 'assets/onboard/onboard.png',
      title: 'Reporting Locations',
      discription: 'Check bins dropped by others and report if bins are missing or wrong.This feedback helps us improve accuracy over time.'
      )
];
