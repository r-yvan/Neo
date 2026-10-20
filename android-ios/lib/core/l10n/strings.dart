/// Global text catalog. English is the source of truth; Kinyarwanda mirrors
/// every key in [SRw]. Fixing one string therefore means editing one line
/// here — no code changes required.
///
/// There is a single global instance ([L10n.i]) that is swapped when the
/// language changes; because the whole tree repaints on locale change
/// (MaterialApp is rebuilt by the language provider), every screen re-reads
/// the getters on rebuild.
abstract class S {
  // ------------------------------------------------------------------ common
  String get appTitle;
  String get commonContinue;
  String get commonCancel;
  String get commonConfirm;
  String get commonSave;
  String get commonSaving;
  String get commonRemove;
  String get commonRetry;
  String get commonLoading;
  String get commonOk;
  String get commonYes;
  String get commonNo;
  String get commonDone;
  String get commonBack;
  String get commonSkip;
  String get commonClose;
  String get commonEdit;
  String get commonDelete;
  String get commonSubmit;
  String get commonSend;
  String get commonSelect;
  String get commonConfirmCaps;
  String get commonCamera;
  String get commonGallery;
  String get commonPhoto;
  String get commonPhone;
  String get commonPassword;
  String get commonSearch;
  String commonSaveFailed(String message);
  String get commonNetworkError;
  String get cancelled;
  String get relJustNow;
  String relMinutesAgo(int minutes);
  String relHoursAgo(int hours);
  String relDaysAgo(int days);

  // ---------------------------------------------------------------- language
  String get languageSheetTitle;
  String get languageSystem;
  String get languageEnglish;
  String get languageKinyarwanda;
  String get languageNavHint;

  // --------------------------------------------------------------- onboarding
  String get onbRentEyebrow;
  String get onbRentTitle;
  String get onbRentBody;
  String get onbTrustEyebrow;
  String get onbTrustTitle;
  String get onbTrustBody;
  String get onbEarnEyebrow;
  String get onbEarnTitle;
  String get onbEarnBody;
  String get onbFootnote;
  String get onbGetStarted;
  String get chipChairs;
  String get chipTables;
  String get chipTents;
  String get chipSound;
  String get chipPower;
  String get chipDecor;
  String get chipTopRated;

  // ------------------------------------------------------------------- splash
  String get splashTagline;

  // --------------------------------------------------------------- navigation
  String get navExplore;
  String get navBookings;
  String get navSaved;
  String get navMessages;
  String get navMyGear;
  String get navListGear;
  String get navProfile;

  // ------------------------------------------------------- become-owner prompt
  String get ownerPromptTitle;
  String get ownerPromptBody;
  String get ownerBenefit1Title;
  String get ownerBenefit1Body;
  String get ownerBenefit2Title;
  String get ownerBenefit2Body;
  String get ownerBenefit3Title;
  String get ownerBenefit3Body;
  String get ownerBenefit4Title;
  String get ownerBenefit4Body;
  String get ownerBecomeCta;
  String get ownerGrantedSnack;
  String get ownerFootnote;

  // ------------------------------------------------------------------ profile
  String get profileNotSignedIn;
  String get profileTitle;
  String get badgeVerified;
  String get badgePendingReview;
  String get badgeUnverified;
  String get badgeOwner;
  String get accountTitle;
  String get accountEditProfile;
  String get accountEditSubtitle;
  String get accountChangePassword;
  String get accountNationalId;
  String get accountIdVerified;
  String get accountIdPending;
  String get accountIdUnlock;
  String get accountBecomeOwner;
  String get accountBecomeOwnerSub;
  String get accountOwnerGranted;
  String get accountSignOut;
  String get signOutTitle;
  String get signOutMessage;
  String get profilePhotoSheetTitle;
  String get profilePhotoSheetHint;
  String get imageFieldLabel;
  String get profilePhotoUpdated;
  String get actSectionTitle;
  String get actMyBookings;
  String get actSavedListings;
  String get actOwnerDashboard;
  String get actMyReviews;
  String get actNotifications;
  String get prefsSectionTitle;
  String get prefsAppearance;
  String get prefsAppearanceLight;
  String get prefsAppearanceDark;
  String get prefsFollowSystem;
  String get prefsLanguage;
  String get prefsLanguageSystem;
  String get prefsLanguageEnglish;
  String get prefsLanguageKinyarwanda;
  String get supportSectionTitle;
  String get supportIntro;
  String get supportCall;
  String get supportEmail;
  String supportDial(String phone);
  String supportWrite(String email);
  String get editProfileSheetTitle;
  String get fieldFullName;
  String get fieldEmailOptional;
  String get profileSavedSnack;
  String get passwordSheetTitle;
  String get fieldCurrentPassword;
  String get fieldNewPassword;
  String get passwordUpdatedSnack;
  String get idSheetTitle;
  String get idSheetHint;
  String get fieldNationalId;
  String get idSubmittedSnack;
  String get idVerifiedSnack;
  String get idWaitingSnack;
}

/// English source strings.
class SEn implements S {
  const SEn();

  @override
  String get appTitle => 'Neo — Event Equipment Rental';
  @override
  String get commonContinue => 'Continue';
  @override
  String get commonCancel => 'Cancel';
  @override
  String get commonConfirm => 'Confirm';
  @override
  String get commonSave => 'Save';
  @override
  String get commonSaving => 'Saving…';
  @override
  String get commonRemove => 'Remove';
  @override
  String get commonRetry => 'Retry';
  @override
  String get commonLoading => 'Loading…';
  @override
  String get commonOk => 'OK';
  @override
  String get commonYes => 'Yes';
  @override
  String get commonNo => 'No';
  @override
  String get commonDone => 'Done';
  @override
  String get commonBack => 'Back';
  @override
  String get commonSkip => 'Skip';
  @override
  String get commonClose => 'Close';
  @override
  String get commonEdit => 'Edit';
  @override
  String get commonDelete => 'Delete';
  @override
  String get commonSubmit => 'Submit';
  @override
  String get commonSend => 'Send';
  @override
  String get commonSelect => 'Select';
  @override
  String get commonConfirmCaps => 'CONFIRM';
  @override
  String get commonCamera => 'Camera';
  @override
  String get commonGallery => 'Gallery';
  @override
  String get commonPhoto => 'Photo';
  @override
  String get commonPhone => 'Phone';
  @override
  String get commonPassword => 'Password';
  @override
  String get commonSearch => 'Search';
  @override
  String commonSaveFailed(String message) => 'Could not save: $message';
  @override
  String get commonNetworkError =>
      'Network error — check your connection and try again.';
  @override
  String get cancelled => 'Cancelled';
  @override
  String get relJustNow => 'just now';
  @override
  String relMinutesAgo(int minutes) => '${minutes}m ago';
  @override
  String relHoursAgo(int hours) => '${hours}h ago';
  @override
  String relDaysAgo(int days) => '${days}d ago';

  // language
  @override
  String get languageSheetTitle => 'Language';
  @override
  String get languageSystem => 'Follow system';
  @override
  String get languageEnglish => 'English';
  @override
  String get languageKinyarwanda => 'Kinyarwanda';
  @override
  String get languageNavHint => 'You can always change this later in Profile.';

  // onboarding
  @override
  String get onbRentEyebrow => 'Rent anything';
  @override
  String get onbRentTitle => 'Every event starts\nwith equipment';
  @override
  String get onbRentBody =>
      'Chairs, tables, tents, sound, power and decor — from verified owners across Kigali and beyond.';
  @override
  String get onbTrustEyebrow => 'Book with confidence';
  @override
  String get onbTrustTitle => 'Clear prices.\nNo surprises.';
  @override
  String get onbTrustBody =>
      'See the daily rate, the deposit and the exact total before you pay. Pay with MTN MoMo or Airtel Money.';
  @override
  String get onbEarnEyebrow => 'Earn from your gear';
  @override
  String get onbEarnTitle => 'Your idle chairs\nshould pay rent';
  @override
  String get onbEarnBody =>
      'List your equipment in minutes, accept the bookings you want, and get paid straight to your mobile money.';
  @override
  String get onbFootnote =>
      'Free to browse · 10% platform fee only on completed rentals';
  @override
  String get onbGetStarted => 'Get started';
  @override
  String get chipChairs => 'Chairs';
  @override
  String get chipTables => 'Tables';
  @override
  String get chipTents => 'Tents';
  @override
  String get chipSound => 'Sound';
  @override
  String get chipPower => 'Power';
  @override
  String get chipDecor => 'Decor';
  @override
  String get chipTopRated => 'Top rated';

  // splash
  @override
  String get splashTagline => 'Event equipment, ready when you are';

  // navigation
  @override
  String get navExplore => 'Explore';
  @override
  String get navBookings => 'Bookings';
  @override
  String get navSaved => 'Saved';
  @override
  String get navMessages => 'Chat';
  @override
  String get navMyGear => 'My gear';
  @override
  String get navListGear => 'List gear';
  @override
  String get navProfile => 'Profile';

  // become-owner prompt
  @override
  String get ownerPromptTitle => 'Turn your gear\ninto income';
  @override
  String get ownerPromptBody =>
      'Owners on Neo list chairs, tents, sound systems and generators and get paid for every completed rental. You keep 90% — we take a 10% commission.';
  @override
  String get ownerBenefit1Title => 'List in under a minute';
  @override
  String get ownerBenefit1Body =>
      'Photos, a daily price and the number of units. That is all we need.';
  @override
  String get ownerBenefit2Title => 'You choose every booking';
  @override
  String get ownerBenefit2Body =>
      'Requests arrive for review. Accept only the dates that suit you.';
  @override
  String get ownerBenefit3Title => 'Paid to your MoMo';
  @override
  String get ownerBenefit3Body =>
      'Payouts land after each rental, and you can withdraw any time.';
  @override
  String get ownerBenefit4Title => 'Boost to be seen first';
  @override
  String get ownerBenefit4Body =>
      'Pay a small fee to appear at the top of search results for a few days.';
  @override
  String get ownerBecomeCta => 'Become an owner';
  @override
  String get ownerGrantedSnack => 'You can now list your equipment';
  @override
  String get ownerFootnote =>
      'Your first five listings are free. Verify your national ID to unlock payouts.';

  // profile
  @override
  String get profileNotSignedIn => 'Not signed in';
  @override
  String get profileTitle => 'Profile';
  @override
  String get badgeVerified => 'Verified';
  @override
  String get badgePendingReview => 'Pending review';
  @override
  String get badgeUnverified => 'Unverified';
  @override
  String get badgeOwner => 'Owner';
  @override
  String get accountTitle => 'Account';
  @override
  String get accountEditProfile => 'Edit profile';
  @override
  String get accountEditSubtitle => 'Name and email';
  @override
  String get accountChangePassword => 'Change password';
  @override
  String get accountNationalId => 'National ID';
  @override
  String get accountIdVerified => 'Verified ✓';
  @override
  String get accountIdPending => 'Pending review';
  @override
  String get accountIdUnlock => 'Verify to unlock payouts';
  @override
  String get accountBecomeOwner => 'Become an owner';
  @override
  String get accountBecomeOwnerSub => 'List your equipment and earn';
  @override
  String get accountOwnerGranted => 'You can now list your equipment';
  @override
  String get accountSignOut => 'Sign out';
  @override
  String get signOutTitle => 'Sign out?';
  @override
  String get signOutMessage =>
      'You will need your phone number to sign back in.';
  @override
  String get profilePhotoSheetTitle => 'Profile photo';
  @override
  String get profilePhotoSheetHint =>
      'Paste a photo URL for now — in-app uploads come next.';
  @override
  String get imageFieldLabel => 'Image URL';
  @override
  String get profilePhotoUpdated => 'Photo updated';
  @override
  String get actSectionTitle => 'Activity';
  @override
  String get actMyBookings => 'My bookings';
  @override
  String get actSavedListings => 'Saved listings';
  @override
  String get actOwnerDashboard => 'Owner dashboard';
  @override
  String get actMyReviews => 'My reviews';
  @override
  String get actNotifications => 'Notifications';
  @override
  String get prefsSectionTitle => 'Preferences';
  @override
  String get prefsAppearance => 'Appearance';
  @override
  String get prefsAppearanceLight => 'Light';
  @override
  String get prefsAppearanceDark => 'Dark';
  @override
  String get prefsFollowSystem => 'Follow system';
  @override
  String get prefsLanguage => 'Language';
  @override
  String get prefsLanguageSystem => 'System';
  @override
  String get prefsLanguageEnglish => 'English';
  @override
  String get prefsLanguageKinyarwanda => 'Kinyarwanda';
  @override
  String get supportSectionTitle => 'Support';
  @override
  String get supportIntro =>
      'Need a hand? The Neo team answers MoMo-number calls Monday to Saturday, 8:00–18:00.';
  @override
  String get supportCall => 'Call support';
  @override
  String get supportEmail => 'Email';
  @override
  String supportDial(String phone) => 'Dial $phone';
  @override
  String supportWrite(String email) => 'Write to $email';
  @override
  String get editProfileSheetTitle => 'Edit profile';
  @override
  String get fieldFullName => 'Full name';
  @override
  String get fieldEmailOptional => 'Email (optional)';
  @override
  String get profileSavedSnack => 'Profile saved';
  @override
  String get passwordSheetTitle => 'Change password';
  @override
  String get fieldCurrentPassword => 'Current password';
  @override
  String get fieldNewPassword => 'New password (8+ characters)';
  @override
  String get passwordUpdatedSnack => 'Password updated';
  @override
  String get idSheetTitle => 'Verify your national ID';
  @override
  String get idSheetHint =>
      'This unlocks payouts. A moderator reviews new IDs.';
  @override
  String get fieldNationalId => 'National ID number';
  @override
  String get idSubmittedSnack => 'Submitted for review';
  @override
  String get idVerifiedSnack => 'Your ID is verified';
  @override
  String get idWaitingSnack => 'Submitted — waiting for moderator review';
}

/// Kinyarwanda translations.
class SRw implements S {
  const SRw();

  @override
  String get appTitle => 'Neo — Kurenda ibikoresho by\'ibirori';
  @override
  String get commonContinue => 'Komeza';
  @override
  String get commonCancel => 'Reka';
  @override
  String get commonConfirm => 'Emeza';
  @override
  String get commonSave => 'Bika';
  @override
  String get commonSaving => 'Birabikwa…';
  @override
  String get commonRemove => 'Kuraho';
  @override
  String get commonRetry => 'Gerageza';
  @override
  String get commonLoading => 'Tegereza gato…';
  @override
  String get commonOk => 'Yego';
  @override
  String get commonYes => 'Yego';
  @override
  String get commonNo => 'Oya';
  @override
  String get commonDone => 'Byarangiye';
  @override
  String get commonBack => 'Subira inyuma';
  @override
  String get commonSkip => 'Hanyuma';
  @override
  String get commonClose => 'Funga';
  @override
  String get commonEdit => 'Hindura';
  @override
  String get commonDelete => 'Siba';
  @override
  String get commonSubmit => 'Ohereza';
  @override
  String get commonSend => 'Kohereza';
  @override
  String get commonSelect => 'Hitamo';
  @override
  String get commonConfirmCaps => 'EMEZA';
  @override
  String get commonCamera => 'Kamera';
  @override
  String get commonGallery => 'Galeri';
  @override
  String get commonPhoto => 'Ishusho';
  @override
  String get commonPhone => 'Telefone';
  @override
  String get commonPassword => 'Ijambobanga';
  @override
  String get commonSearch => 'Shakisha';
  @override
  String commonSaveFailed(String message) => 'Kubika byanze: $message';
  @override
  String get commonNetworkError =>
      'Ikosa rya interineti — reba interineti, ubwongere ugerageze.';
  @override
  String get cancelled => 'Byahagaritswe';
  @override
  String get relJustNow => 'Ubu';
  @override
  String relMinutesAgo(int minutes) => 'Hashize iminota $minutes';
  @override
  String relHoursAgo(int hours) => 'Hashize isaha $hours';
  @override
  String relDaysAgo(int days) => 'Hashize iminsi $days';

  // language
  @override
  String get languageSheetTitle => 'Ururimi';
  @override
  String get languageSystem => 'Kurikira sisitemu';
  @override
  String get languageEnglish => 'Icyongereza';
  @override
  String get languageKinyarwanda => 'Ikinyarwanda';
  @override
  String get languageNavHint => 'Ushobora kubihindura nyuma kuri Umwirondoro.';

  // onboarding
  @override
  String get onbRentEyebrow => 'Kurenda byose';
  @override
  String get onbRentTitle => 'Ibikoresho\nni ntangiro y\'ibirori';
  @override
  String get onbRentBody =>
      'Intebe, ameza, amahema, amajwi, ingufu na Deko — biva ku bantu bemejwe, mu Kigali no kure ya Kigali.';
  @override
  String get onbTrustEyebrow => 'Fata umwanya wumvikana';
  @override
  String get onbTrustTitle => 'Ibiciro bisobanutse.\nNta mpinduka.';
  @override
  String get onbTrustBody =>
      'Ubona igiciro cy\'umunsi, depozite n\'umubare nyabwo mbere yo kwishyura. Ushyura na MTN MoMo cyangwa Airtel Money.';
  @override
  String get onbEarnEyebrow => 'Winjiza amafaranga';
  @override
  String get onbEarnTitle => 'Ibikoresho bigeze\nbigendereze amafaranga';
  @override
  String get onbEarnBody =>
      'Shyiraho ibikoresho byawe mu minota mike, hitamo umwanya ushaka, amafaranga agusige ashira kuri MoMo yawe.';
  @override
  String get onbFootnote =>
      'Kureba ni ubuntu · Iciciro cya 10% cyishyurwa gusa ku myanya yarangiye';
  @override
  String get onbGetStarted => 'Tangira';
  @override
  String get chipChairs => 'Intebe';
  @override
  String get chipTables => 'Ameza';
  @override
  String get chipTents => 'Amahema';
  @override
  String get chipSound => 'Amajwi';
  @override
  String get chipPower => 'Ingufu';
  @override
  String get chipDecor => 'Deko';
  @override
  String get chipTopRated => 'Byakunzwe cyane';

  // splash
  @override
  String get splashTagline =>
      'Ibikoresho by\'ibirori, biriho igihe cyose ubishaka';

  // navigation
  @override
  String get navExplore => 'Shakisha';
  @override
  String get navBookings => 'Imyanya';
  @override
  String get navSaved => 'Ibyabitswe';
  @override
  String get navMessages => 'Ubutumwa';
  @override
  String get navMyGear => 'Ibikoresho byanjye';
  @override
  String get navListGear => 'Ongeraho ibikoresho';
  @override
  String get navProfile => 'Umwirondoro';

  // become-owner prompt
  @override
  String get ownerPromptTitle => 'Ibikoresho byawe\nbigane amafaranga';
  @override
  String get ownerPromptBody =>
      'Abafite bashyiraho intebe, amahema, amajwi no za generator kuri Neo, kandi banishyura ku myanya yuzuye yose. Wisigaza 90% — dufata 10%.';
  @override
  String get ownerBenefit1Title => 'Shyiraho munsi y\'umunota';
  @override
  String get ownerBenefit1Body =>
      'Amafoto, igiciro cy\'umunsi no nimero y\'ibikoresho. Ibyo ni byo usaba.';
  @override
  String get ownerBenefit2Title => 'Ni wowe uhita umwanya umwanya';
  @override
  String get ownerBenefit2Body =>
      'Ibyungo biza ngo byisuzumwe. Emeza gusa itariki zihuye na wewe.';
  @override
  String get ownerBenefit3Title => 'Kwishyurirwa kuri MoMo';
  @override
  String get ownerBenefit3Body =>
      'Amafaranga ashira kuri MoMo nyuma y\'umwanya urangiye. Ushobora kuhabona igihe cyose.';
  @override
  String get ownerBenefit4Title => 'Boost uzeho umwanya wa mbere';
  @override
  String get ownerBenefit4Body =>
      'Ishyura ikiguzi gito ngo uve abwambere kuri cache ku myansi mike.';
  @override
  String get ownerBecomeCta => 'Ongera ibikoresho byawe';
  @override
  String get ownerGrantedSnack => 'Ubu ushobora gushyiraho ibikoresho byawe';
  @override
  String get ownerFootnote =>
      'Ibikoresho bitanu byambere ni ubuntu. Emeza ID yawe ya kavukire kugirango ubone kwishyura.';

  // profile
  @override
  String get profileNotSignedIn => 'Ntawe winjije';
  @override
  String get profileTitle => 'Umwirondoro';
  @override
  String get badgeVerified => 'Yemejwe';
  @override
  String get badgePendingReview => 'Birategereza';
  @override
  String get badgeUnverified => 'Ntibyemejwe';
  @override
  String get badgeOwner => 'Umufite';
  @override
  String get accountTitle => 'Konti';
  @override
  String get accountEditProfile => 'Hindura umwirondoro';
  @override
  String get accountEditSubtitle => 'Izina n\'imeri';
  @override
  String get accountChangePassword => 'Hindura ijambobanga';
  @override
  String get accountNationalId => 'ID ya kavukire';
  @override
  String get accountIdVerified => 'Yemejwe ✓';
  @override
  String get accountIdPending => 'Birategereza';
  @override
  String get accountIdUnlock => 'Emeza kugira ngo ubone kwishyura';
  @override
  String get accountBecomeOwner => 'Ongera ibikoresho byawe';
  @override
  String get accountBecomeOwnerSub => 'Shyiraho ibikoresho byawe no kubyora amafaranga';
  @override
  String get accountOwnerGranted => 'Ubu ushobora gushyiraho ibikoresho byawe';
  @override
  String get accountSignOut => 'Sohoka';
  @override
  String get signOutTitle => 'Sohoka?';
  @override
  String get signOutMessage =>
      'Uzakeneye nimero ya telefone kugira ngo winjire ubutaha.';
  @override
  String get profilePhotoSheetTitle => 'Ishusho y\'umwirondoro';
  @override
  String get profilePhotoSheetHint =>
      'Shyira URL y\'ishusho ubu — kuzishyiramo mu app bizaza ubutaha.';
  @override
  String get imageFieldLabel => 'URL y\'ishusho';
  @override
  String get profilePhotoUpdated => 'Ishusho yahinduwe';
  @override
  String get actSectionTitle => 'Ibikorwa';
  @override
  String get actMyBookings => 'Imyanya yange';
  @override
  String get actSavedListings => 'Ibikoresho byabitswe';
  @override
  String get actOwnerDashboard => 'Dashboard y\'umufite';
  @override
  String get actMyReviews => 'Ibitekerezo byanjye';
  @override
  String get actNotifications => 'Amatangazo';
  @override
  String get prefsSectionTitle => 'Inyifato';
  @override
  String get prefsAppearance => 'Isura';
  @override
  String get prefsAppearanceLight => 'Urumuri';
  @override
  String get prefsAppearanceDark => 'Uwigarane';
  @override
  String get prefsFollowSystem => 'Kurikira sisitemu';
  @override
  String get prefsLanguage => 'Ururimi';
  @override
  String get prefsLanguageSystem => 'Sisitemu';
  @override
  String get prefsLanguageEnglish => 'English';
  @override
  String get prefsLanguageKinyarwanda => 'Kirwanda';
  @override
  String get supportSectionTitle => 'Ubufasha';
  @override
  String get supportIntro =>
      'Ukeneye ubufasha? Timu ya Neo yananeza kuri nimero ya MoMo, kuwa mbere kuwa gatandatu, amasaha 8:00–18:00.';
  @override
  String get supportCall => 'Hamagara ubufasha';
  @override
  String get supportEmail => 'Imeri';
  @override
  String supportDial(String phone) => 'Hamagara $phone';
  @override
  String supportWrite(String email) => 'Andika kuri $email';
  @override
  String get editProfileSheetTitle => 'Hindura umwirondoro';
  @override
  String get fieldFullName => 'Izina ryuzuye';
  @override
  String get fieldEmailOptional => 'Imeri (ntibyiza)';
  @override
  String get profileSavedSnack => 'Umwirondoro wabitswe';
  @override
  String get passwordSheetTitle => 'Hindura ijambobanga';
  @override
  String get fieldCurrentPassword => 'Ijambobanga rihari';
  @override
  String get fieldNewPassword => 'Ijambobanga rishya (ibiharika 8+)';
  @override
  String get passwordUpdatedSnack => 'Ijambobanga ryahindwe';
  @override
  String get idSheetTitle => 'Emeza ID yawe ya kavukire';
  @override
  String get idSheetHint =>
      'Bifungura ibishyura. ID nshya isuzumwa n\'ukugenzura.';
  @override
  String get fieldNationalId => 'Nimero ya ID';
  @override
  String get idSubmittedSnack => 'Byoherejwe ku isuzuma';
  @override
  String get idVerifiedSnack => 'ID yawe yemejwe';
  @override
  String get idWaitingSnack => 'Byoherejwe — birategereza ku isuzuma';
}

/// Registry + global accessor. Non-widget code (repositories, validators,
/// formatters) reads [L10n.i]; widget code may use it too, because the whole
/// tree repaints whenever the language changes.
abstract final class L10n {
  static S _current = const SEn();

  static S get i => _current;

  /// Swaps the active translation table.
  static void setLanguage(String languageCode) =>
      _current = languageCode == 'rw' ? const SRw() : const SEn();
}
