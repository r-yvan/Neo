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
  String get ratingNew;
  String get errorCouldNotLoad;
  String get errorTryAgain;
  String get photoNoPhotoYet;
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

  // -------------------------------------------------------------- validators
  String get valPhoneEmpty;
  String get valPhonePattern;
  String get valFullNameEmpty;
  String get valFullNameShort;
  String get valEmailInvalid;
  String get valPasswordEmpty;
  String get valPasswordShort;
  String get valIdEmpty;
  String get valIdPattern;
  String get valOtpEmpty;
  String get valOtpPattern;
  String get valTitleEmpty;
  String get valTitleShort;
  String get valDescriptionLong;
  String get valLocationEmpty;
  String get valQuantityNumber;
  String get valQuantityMin;
  String valQuantityMax(int max);
  String get valPriceNumber;
  String get valPriceZero;
  String get valPriceRange;
  String get valFieldRequired;
  String get sessionExpired;

  // ----------------------------------------------------------------- explore
  String get greetingMorning;
  String get greetingAfternoon;
  String get greetingEvening;
  String get exploreHeadline;
  String get exploreSearchHint;
  String get chipAll;
  String itemCount(int count);
  String get filterPriceChip;
  String get commonClear;
  String get emptyNoMatchesTitle;
  String get emptyNoMatchesBody;
  String get emptyNoEquipmentTitle;
  String get emptyNoEquipmentBody;
  String get emptyClearFilters;
  String get endOfList;
  String get catChairs;
  String get catTables;
  String get catTents;
  String get catSpeakers;
  String get catLights;
  String get catCoolers;
  String get catGenerators;
  String get catDecor;
  String get catOther;
  String get filterTitle;
  String get filterWhere;
  String get filterSectorLabel;
  String get filterDailyPrice;
  String get filterAvailableOn;
  String get filterAnyDate;
  String get filterAnyPrice;
  String get filterShowResults;
  String get filterReset;
  String get filterDateHelp;
  String get tooltipNotifications;
  String get badgeBoosted;
  String get badgeUnavailable;
  String get perDay;

  // ------------------------------------------------------------------ enums
  String get catChairsFull;
  String get catTablesFull;
  String get catTentsFull;
  String get catSpeakersFull;
  String get catLightsFull;
  String get catCoolersFull;
  String get catGeneratorsFull;
  String get catDecorFull;
  String get catOtherFull;
  String get statusPending;
  String get statusAccepted;
  String get statusRejected;
  String get statusCancelled;
  String get statusOngoing;
  String get statusCompleted;
  String get statusDisputed;
  String get hintPending;
  String get hintAccepted;
  String get hintRejected;
  String get hintCancelled;
  String get hintOngoing;
  String get hintCompleted;
  String get hintDisputed;
  String get paymentPending;
  String get paymentPaid;
  String get paymentRefunded;
  String get paymentFailed;
  String get rentalPayout;

  // ----------------------------------------------------------- booking flow
  String get flowDates;
  String get flowDatesSub;
  String get flowQuantity;
  String get flowQuantitySub;
  String get flowSummary;
  String get flowSummarySub;
  String get flowPayment;
  String get flowPaymentSub;
  String flowRequestSent(String owner);
  String get flowOwnerFallback;
  String get flowPaymentConfirmed;
  String get flowTitle;
  String get calMonth;
  String get flowBlockedRange;
  String flowBlockedByOwner(int n);
  String get flowOwnerNoteLabel;
  String get flowOwnerNoteHint;
  String get flowUnitsNeeded;
  String get flowEstimatedTotal;
  String get flowOwnListingTitle;
  String get flowOwnListingMessage;
  String flowUnitCount(int n);
  String flowDayCount(int n);
  String get flowSubtotal;
  String get flowPlatformFee;
  String get flowDeposit;
  String get flowYouPayNow;
  String get flowPayNothingYet;
  String flowMessageOwner(String name);
  String get flowAskPickup;
  String get flowNoRequestTitle;
  String get flowNoRequestBody;
  String get flowPaymentCompleteTitle;
  String flowPaymentCompleteBody(String total, String payout);
  String get flowWaitingOwner;
  String flowStatusNote(String status);
  String get flowMessageOwnerCta;
  String get flowAmountDue;
  String get flowPayWith;
  String get momoName;
  String get airtelName;
  String get flowMomoNumber;
  String get flowChooseMethod;
  String flowPayTotal(String total);
  String get flowClose;
  String get flowBack;
  String get flowContinue;
  String get flowSendRequest;
  String get flowContinuePayment;
  String get momoShort;

  String get roleRenter;
  String get roleOwner;
  String get roleAdmin;
  String get bkTitle;
  String get bkTabRenting;
  String get bkTabMine;
  String get bkChipAll;
  String get bkEmptyMine;
  String get bkEmptyOwned;
  String get bkEmptyMineBody;
  String get bkEmptyOwnedBody;
  String get bkBrowseCta;
  String get bkEndList;
  String get bkFallbackTitle;
  String bkPaidInfo(String payout);
  String get bkPaymentPending;
  String get bkDecline;
  String get bkAccept;
  String get bkPayNow;
  String get bdPaymentConfirmed;
  String bdSnack(String status);
  String get bdExtendHelp;
  String get bdNotFound;
  String get bdTitle;
  String get bdTimeline;
  String get bdTotal;
  String get bdDepositRecorded;
  String get bdYouReceive;
  String get bdOwnerReceives;
  String get bdNoActivityTitle;
  String get bdNoActivityBody;
  String get bdActorSystem;
  String bdMessageRenter(String name);
  String bdMessageOwner(String name);
  String get bdAcceptRequest;
  String get bdStart;
  String get bdExtend;
  String get bdComplete;
  String get bdReview;
  String get bdReport;
  String get bdCancel;
  String get bdCancelTitle;
  String get bdCancelBody;
  String get bdDisputeBody;
  String get bdDisputeField;
  String get bdDisputeSubmit;
  String get bdDisputeSnack;

  // ------------------------------------------------------------ equipment
  String get eqLoadingListing;
  String get eqNotFound;
  String get eqPerDay;
  String get eqAvailable;
  String eqStatusOpen(bool open);
  String eqDepositInfo(String amount);
  String get eqAbout;
  String get eqAvailabilityHead;
  String get eqAvailabilitySub;
  String get eqFormerOwnerTag;
  String get eqShareTotal;
  String get eqRangeUnavailable;
  String get eqDayUnavailable;
  String eqTotalFor(int days);
  String get eqTotalPayable;
  String get eqEditListing;
  String get eqMessageOwner;
  String get repMisleading;
  String get repPriceWrong;
  String get repNotAsDescribed;
  String get repOwnerSilent;
  String get repDuplicate;
  String get repOther;
  String get repReasonOther;
  String get repDoneSnack;
  String get repTitle;
  String get repIntro;
  String get repExtraField;
  String get repSubmit;
  String get formGallerySnack;
  String get formUrlHintSnack;
  String formSnack(bool isEdit);
  String formTitle(bool isEdit);
  String get formOwnerRequiredTitle;
  String get formOwnerRequiredBody;
  String get formFieldTitle;
  String get formHintTitle;
  String get formCatLabel;
  String get formPriceLabel;
  String get formUnitsLabel;
  String get formDepositLabel;
  String get formAreaLabel;
  String get formAreaHint;
  String get formDescLabel;
  String get formDescHint;
  String get formAvailButton;
  String formSaveButton(bool isEdit);
  String get formPhotosHead;
  String get formPhotosSub;
  String get formUrlField;
  String get formAddUrl;
  String get formTakePhoto;
  String get avBlockedSnack;
  String get avUnblockedSnack;
  String get avTitle;
  String get avAccepting;
  String avStateNote(bool live);
  String avSwitchTitle(bool live);
  String get avTapHint;
  String avBlockButton(int n);
  String get avBlockedHead;
  String get avNothingBlocked;
  String get avNothingBlockedBody;
  String avActiveOn(int n);
  String get avUnblock;

  // -------------------------------------------------------------------- auth
  String authWelcomeSnack(String name);
  String get fieldNationalIdOptional;
  String get hintIdSixteen;
  String get hintPasswordSix;
  String get authAlreadyHave;
  String get otpVerifyTitle;
  String get otpDefaultSubtitle;
  String get otpVerifyCta;
  String get otpResentSnack;
  String get forgotAppbarTitle;
  String get forgotScreenIntro;
  String get forgotNewPasswordHint;
  String get forgotSendCta;
  String get authWelcomeBack;
  String get authSignInSubtitle;
  String get fieldPhone;
  String get showPassword;
  String get hidePassword;
  String get authForgot;
  String get authSignIn;
  String get authUseOtp;
  String get authNewToNeo;
  String get authCreateAccount;
  String get authEnterPhoneFirst;
  String get authContinueOtpError;
  String otpSentTo(String phone);
  String get otpDevCode;
  String get otpResend;
  String get authRegisterTitle;
  String get authRegisterSubtitle;
  String get authRegister;
  String get authHaveAccount;
  String get authSignInInstead;
  String get authOtpTitle;
  String get authOtpSubtitle;
  String get sectionSecurity;
  String get sectionPersonal;
  String get sectionId;
  String get authOtp;
  String get authPasswordOption;
  String get authPasswordOptionalHint;
  String get fieldConfirmPassword;
  String get valPasswordMismatch;
  String get authIdHint;
  String get authEmailHint;
  String authRegisterFailed(String message);
  String get forgotTitle;
  String get forgotSubtitle;
  String get forgotContinue;
  String get forgotChangeTitle;
  String get forgotChangeSubtitle;
  String get fieldNewPasswordShort;
  String get forgotChangedSnack;

  // -------- Completion: uploads, payments, trust, explore
  String get photoChooseSource;
  String get photoTakeNew;
  String get photoFromGallery;
  String get photoUploading;
  String get photoUploadFailed;
  String get photoCover;
  String get formPhotosTitle;
  String get formPhotosHint;
  String get formPhotosWaitUpload;
  String get avatarChange;
  String get avatarRemove;
  String get avatarUpdated;
  String get avatarRemoved;
  String get payHistoryTitle;
  String get payHistorySubtitle;
  String get payHistoryEmptyTitle;
  String get payHistoryEmptyBody;
  String get payTotalPaid;
  String get payTotalPending;
  String get payTxCount;
  String get txCommission;
  String get txPayout;
  String get txBoost;
  String get txRental;
  String get txWithdrawal;
  String get txRefund;
  String get payRef;
  String get reportsTitle;
  String get reportsEmptyTitle;
  String get reportsEmptyBody;
  String get targetEquipment;
  String get targetUser;
  String get targetReview;
  String get targetMessage;
  String get statusOpen;
  String get statusInReview;
  String get statusResolved;
  String get statusDismissed;
  String get statusClosed;
  String get disputeTitle;
  String get disputeView;
  String get disputeReason;
  String get disputeResponse;
  String get disputeResolution;
  String get disputeNoResponse;
  String get disputeAwaitingDecision;
  String get disputeRespondHint;
  String get disputeRespondField;
  String get disputeRespondSubmit;
  String get disputeResponded;
  String get disputeStepOpened;
  String get disputeStepResponse;
  String get disputeStepDecision;
  String get disputeForBooking;
  String get explorePopular;
  String get exploreNearby;
  String get exploreNearbySub;
  String get actPayments;
  String get actReports;
  String get actAdmin;
  String get actAdminSub;
  String get navUnreadHint;
  String caseStatus(String wire);
  String reportTarget(String wire);

  // -------- Admin console
  String get adminTitle;
  String get adminOverview;
  String get adminUsers;
  String get adminListings;
  String get adminMoney;
  String get adminTrust;
  String get adminBookings;
  String get adminPending;
  String get adminCompleted;
  String get adminRevenue;
  String get adminRevenueSub;
  String get adminOpenReports;
  String get adminOpenDisputes;
  String get adminLast30;
  String get adminNewUsers;
  String get adminNewBookings;
  String get adminTopListings;
  String get adminNeedsAttention;
  String get adminAllClear;
  String get adminVerify;
  String get adminVerified;
  String get adminBan;
  String get adminUnban;
  String get adminBanned;
  String get adminBanConfirmTitle;
  String get adminBanConfirmBody;
  String get adminApprove;
  String get adminReject;
  String get adminApproved;
  String get adminAwaitingApproval;
  String get adminTransactions;
  String get adminReviews;
  String get adminDeleteReview;
  String get adminDeleteReviewBody;
  String get adminReports;
  String get adminDisputes;
  String get adminResolve;
  String get adminDismiss;
  String get adminCloseCase;
  String get adminNoteField;
  String get adminDecisionField;
  String get adminDecisionRequired;
  String get adminSaved;
  String get adminEmpty;
  String get adminEmptyBody;
  String get adminRenter;
  String get adminOwner;
  String adminReportedBy(String name);
  String adminOpenedBy(String name);
  String adminBy(String name);

  // -------- Nearby map
  String get mapTitle;
  String get mapOpen;
  String get mapLayerAll;
  String get mapLayerLenders;
  String get mapLayerBorrowers;
  String get mapLender;
  String get mapBorrower;
  String get mapSearchArea;
  String get mapRecenter;
  String get mapRadius;
  String get mapLoading;
  String get mapEmptyTitle;
  String get mapEmptyBody;
  String get mapUsingDefault;
  String get mapLocationOff;
  String get mapLocationDenied;
  String get mapOpenSettings;
  String get mapFromPrice;
  String get mapViewProfile;
  String get mapMessage;
  String get mapLookingFor;
  String get mapApproxArea;
  String get mapMeTitle;
  String get mapMeSubtitle;
  String get mapMeSwitch;
  String get mapMePrivacy;
  String get mapMeNote;
  String get mapMeNoteHint;
  String get mapMeArea;
  String get mapMeAreaHint;
  String get mapMeUseLocation;
  String get mapMeLocationSet;
  String get mapMeNoLocation;
  String get mapMeRemove;
  String get mapMeSaved;
  String get mapMeRemoved;
  String get mapMeYou;
  String get mapMeVisible;
  String get mapMeHidden;
  String get mapAttribution;
  String mapKmAway(double km);
  String mapListings(int n);
  String mapRadiusKm(int km);
  String mapActive(String when);
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
  String get ratingNew => 'New';
  @override
  String get errorCouldNotLoad => 'Could not load';
  @override
  String get errorTryAgain => 'Try again';
  @override
  String get photoNoPhotoYet => 'No photo yet';
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

  // -------------------------------------------------------------- validators
  @override
  String get valPhoneEmpty => 'Enter your phone number';
  @override
  String get valPhonePattern => 'Enter a valid Rwandan number, e.g. 0780000000';
  @override
  String get valFullNameEmpty => 'Enter your full name';
  @override
  String get valFullNameShort => 'That name looks too short';
  @override
  String get valEmailInvalid => 'Enter a valid email address';
  @override
  String get valPasswordEmpty => 'Choose a password';
  @override
  String get valPasswordShort => 'Use at least 6 characters';
  @override
  String get valIdEmpty => 'Enter your national ID';
  @override
  String get valIdPattern => 'A national ID is 16 digits';
  @override
  String get valOtpEmpty => 'Enter the 6-digit code';
  @override
  String get valOtpPattern => 'The code is 6 digits';
  @override
  String get valTitleEmpty => 'Give your listing a title';
  @override
  String get valTitleShort => 'Use at least 4 characters';
  @override
  String get valDescriptionLong => 'Keep it under 2000 characters';
  @override
  String get valLocationEmpty => 'Where can the item be collected?';
  @override
  String get valQuantityNumber => 'Enter a number';
  @override
  String get valQuantityMin => 'At least 1';
  @override
  String valQuantityMax(int max) => 'That is more than $max';
  @override
  String get valPriceNumber => 'Enter a price in RWF';
  @override
  String get valPriceZero => 'The price must be more than 0';
  @override
  String get valPriceRange => 'That price is out of range';
  @override
  String get valFieldRequired => 'This field is required';
  @override
  String get sessionExpired => 'Your session expired. Please sign in again.';

  // --------------------------------------------------------------- explore
  @override
  String get greetingMorning => 'Good morning';
  @override
  String get greetingAfternoon => 'Good afternoon';
  @override
  String get greetingEvening => 'Good evening';
  @override
  String get exploreHeadline => 'Find your event gear';
  @override
  String get exploreSearchHint => 'Chairs, tents, speakers…';
  @override
  String get chipAll => 'All';
  @override
  String itemCount(int count) => '$count items';
  @override
  String get filterPriceChip => 'Price filter';
  @override
  String get commonClear => 'Clear';
  @override
  String get emptyNoMatchesTitle => 'No matches';
  @override
  String get emptyNoMatchesBody => 'Try a different category, area or price range.';
  @override
  String get emptyNoEquipmentTitle => 'No equipment yet';
  @override
  String get emptyNoEquipmentBody => 'Be the first to list chairs, tables or sound on Neo.';
  @override
  String get emptyClearFilters => 'Clear filters';
  @override
  String get endOfList => 'That is everything for now';
  @override
  String get catChairs => 'Chairs';
  @override
  String get catTables => 'Tables';
  @override
  String get catTents => 'Tents';
  @override
  String get catSpeakers => 'Sound';
  @override
  String get catLights => 'Lights';
  @override
  String get catCoolers => 'Coolers';
  @override
  String get catGenerators => 'Power';
  @override
  String get catDecor => 'Decor';
  @override
  String get catOther => 'Other';
  @override
  String get filterTitle => 'Filters';
  @override
  String get filterWhere => 'Where';
  @override
  String get filterSectorLabel => 'Sector or district';
  @override
  String get filterDailyPrice => 'Daily price (RWF)';
  @override
  String get filterAvailableOn => 'Available on';
  @override
  String get filterAnyDate => 'Any date';
  @override
  String get filterAnyPrice => 'Any';
  @override
  String get filterShowResults => 'Show results';
  @override
  String get filterReset => 'Reset';
  @override
  String get filterDateHelp => 'When do you need it?';
  @override
  String get tooltipNotifications => 'Notifications';
  @override
  String get badgeBoosted => 'Boosted';
  @override
  String get badgeUnavailable => 'Unavailable';
  @override
  String get perDay => '/day';

  // ------------------------------------------------------------------ enums
  @override
  String get catChairsFull => 'Chairs & Seating';
  @override
  String get catTablesFull => 'Tables & High Tables';
  @override
  String get catTentsFull => 'Tents & Canopies';
  @override
  String get catSpeakersFull => 'Sound & Audio';
  @override
  String get catLightsFull => 'Lighting & Stage FX';
  @override
  String get catCoolersFull => 'Coolers & Catering';
  @override
  String get catGeneratorsFull => 'Power & Generators';
  @override
  String get catDecorFull => 'Decorations & Backdrops';
  @override
  String get catOtherFull => 'Other Event Supplies';
  @override
  String get statusPending => 'Pending';
  @override
  String get statusAccepted => 'Accepted';
  @override
  String get statusRejected => 'Rejected';
  @override
  String get statusCancelled => 'Cancelled';
  @override
  String get statusOngoing => 'Ongoing';
  @override
  String get statusCompleted => 'Completed';
  @override
  String get statusDisputed => 'Disputed';
  @override
  String get hintPending => 'Waiting for the owner to respond';
  @override
  String get hintAccepted => 'Confirmed — arrange the handover';
  @override
  String get hintRejected => 'The owner declined this request';
  @override
  String get hintCancelled => 'This booking was cancelled';
  @override
  String get hintOngoing => 'The rental is in progress';
  @override
  String get hintCompleted => 'Rental finished';
  @override
  String get hintDisputed => 'Under dispute review';
  @override
  String get paymentPending => 'Pending';
  @override
  String get paymentPaid => 'Paid';
  @override
  String get paymentRefunded => 'Refunded';
  @override
  String get paymentFailed => 'Failed';
  @override
  String get rentalPayout => 'Rental payout';

  // ----------------------------------------------------------- booking flow
  @override
  String get flowDates => 'Dates';
  @override
  String get flowDatesSub => 'When do you need it?';
  @override
  String get flowQuantity => 'Quantity';
  @override
  String get flowQuantitySub => 'How many units?';
  @override
  String get flowSummary => 'Summary';
  @override
  String get flowSummarySub => 'Check the details';
  @override
  String get flowPayment => 'Payment';
  @override
  String get flowPaymentSub => 'Pay with mobile money';
  @override
  String flowRequestSent(String owner) => 'Request sent to $owner.';
  @override
  String get flowOwnerFallback => 'the owner';
  @override
  String get flowPaymentConfirmed => 'Payment confirmed. The owner has been notified.';
  @override
  String get flowTitle => 'Request to book';
  @override
  String get calMonth => 'Month';
  @override
  String get flowBlockedRange => 'That range includes an unavailable day';
  @override
  String flowBlockedByOwner(int n) => '$n day${n == 1 ? '' : 's'} blocked by the owner.';
  @override
  String get flowOwnerNoteLabel => 'Note for the owner (optional)';
  @override
  String get flowOwnerNoteHint => 'Event type, delivery details, pickup time…';
  @override
  String get flowUnitsNeeded => 'Units needed';
  @override
  String get flowEstimatedTotal => 'Estimated total';
  @override
  String get flowOwnListingTitle => 'This is your listing';
  @override
  String get flowOwnListingMessage =>
      'You cannot rent your own equipment. Manage it from the My gear tab instead.';
  @override
  String flowUnitCount(int n) => '$n unit${n == 1 ? '' : 's'}';
  @override
  String flowDayCount(int n) => '$n day${n == 1 ? '' : 's'}';
  @override
  String get flowSubtotal => 'Rental subtotal';
  @override
  String get flowPlatformFee => 'Platform fee (10%)';
  @override
  String get flowDeposit => 'Refundable deposit (recorded)';
  @override
  String get flowYouPayNow => 'You pay now';
  @override
  String get flowPayNothingYet =>
      'Nothing is charged yet. The owner reviews your request first — '
      'you pay only after they accept.';
  @override
  String flowMessageOwner(String name) => 'Message $name';
  @override
  String get flowAskPickup => 'Ask about pickup or delivery';
  @override
  String get flowNoRequestTitle => 'No request yet';
  @override
  String get flowNoRequestBody =>
      'Go back to the summary and send your booking request first.';
  @override
  String get flowPaymentCompleteTitle => 'Payment complete';
  @override
  String flowPaymentCompleteBody(String total, String payout) =>
      'You paid $total. The owner keeps $payout and Neo keeps the 10% fee.';
  @override
  String get flowWaitingOwner => 'Waiting for the owner';
  @override
  String flowStatusNote(String status) =>
      'Your request status is ${status.toLowerCase()}. '
      'You will get a notification the moment the owner responds, and '
      'payment unlocks then.';
  @override
  String get flowMessageOwnerCta => 'Message the owner';
  @override
  String get flowAmountDue => 'Amount due';
  @override
  String get flowPayWith => 'Pay with';
  @override
  String get momoName => 'MTN Rwanda';
  @override
  String get airtelName => 'Airtel Rwanda';
  @override
  String get flowMomoNumber => 'Mobile money number';
  @override
  String get flowChooseMethod => 'Choose a payment method';
  @override
  String flowPayTotal(String total) => 'Pay $total';
  @override
  String get flowClose => 'Close';
  @override
  String get flowBack => 'Back';
  @override
  String get flowContinue => 'Continue';
  @override
  String get flowSendRequest => 'Send booking request';
  @override
  String get flowContinuePayment => 'Continue to payment';
  @override
  String get momoShort => 'MoMo';

  @override
  String get roleRenter => 'Renter';
  @override
  String get roleOwner => 'Owner';
  @override
  String get roleAdmin => 'Admin';
  @override
  String get bkTitle => 'Bookings';
  @override
  String get bkTabRenting => 'Renting';
  @override
  String get bkTabMine => 'My items';
  @override
  String get bkChipAll => 'All';
  @override
  String get bkEmptyMine => 'No bookings yet';
  @override
  String get bkEmptyOwned => 'No requests yet';
  @override
  String get bkEmptyMineBody => 'Find equipment on Explore and send your first rental request.';
  @override
  String get bkEmptyOwnedBody => 'When a renter requests one of your items, it will appear here.';
  @override
  String get bkBrowseCta => 'Browse equipment';
  @override
  String get bkEndList => 'No more bookings';
  @override
  String get bkFallbackTitle => 'Booking';
  @override
  String bkPaidInfo(String payout) => 'Paid · owner receives $payout';
  @override
  String get bkPaymentPending => 'Payment pending';
  @override
  String get bkDecline => 'Decline';
  @override
  String get bkAccept => 'Accept';
  @override
  String get bkPayNow => 'Pay now';
  @override
  String get bdPaymentConfirmed => 'Payment confirmed';
  @override
  String bdSnack(String status) => 'Booking $status';
  @override
  String get bdExtendHelp => 'New end date';
  @override
  String get bdNotFound => 'Not found';
  @override
  String get bdTitle => 'Booking';
  @override
  String get bdTimeline => 'Timeline';
  @override
  String get bdTotal => 'Rental total';
  @override
  String get bdDepositRecorded => 'Deposit recorded';
  @override
  String get bdYouReceive => 'You receive';
  @override
  String get bdOwnerReceives => 'Owner receives';
  @override
  String get bdNoActivityTitle => 'No activity yet';
  @override
  String get bdNoActivityBody => 'Status changes will appear here.';
  @override
  String get bdActorSystem => 'System';
  @override
  String bdMessageRenter(String name) => 'Message $name';
  @override
  String bdMessageOwner(String name) => 'Message $name';
  @override
  String get bdAcceptRequest => 'Accept request';
  @override
  String get bdStart => 'Start rental';
  @override
  String get bdExtend => 'Extend rental';
  @override
  String get bdComplete => 'Mark as completed';
  @override
  String get bdReview => 'Leave a review';
  @override
  String get bdReport => 'Report a problem';
  @override
  String get bdCancel => 'Cancel booking';
  @override
  String get bdCancelTitle => 'Cancel this booking?';
  @override
  String get bdCancelBody => 'This cannot be undone. Ask the other party first if you can.';
  @override
  String get bdDisputeBody => 'A dispute pauses the booking while the Neo team reviews both sides.';
  @override
  String get bdDisputeField => 'What went wrong?';
  @override
  String get bdDisputeSubmit => 'Open dispute';
  @override
  String get bdDisputeSnack => 'Dispute opened. We will be in touch.';

  // ------------------------------------------------------------ equipment
  @override
  String get eqLoadingListing => 'Loading listing…';
  @override
  String get eqNotFound => 'Not found';
  @override
  String get eqPerDay => 'Per day';
  @override
  String get eqAvailable => 'Available';
  @override
  String eqStatusOpen(bool open) => open ? 'Ready to rent' : 'Paused';
  @override
  String eqDepositInfo(String amount) =>
      'A refundable deposit of $amount is recorded with the booking.';
  @override
  String get eqAbout => 'About this equipment';
  @override
  String get eqAvailabilityHead => 'Availability';
  @override
  String get eqAvailabilitySub =>
      'Pick your rental dates. Blocked days cannot be booked.';
  @override
  String get eqFormerOwnerTag => 'New owner';
  @override
  String get eqShareTotal => 'Select your dates on the calendar to see the total.';
  @override
  String get eqRangeUnavailable => 'Your range includes an unavailable day';
  @override
  String get eqDayUnavailable => 'That day is not available';
  @override
  String eqTotalFor(int days) => days == 1 ? 'Total for 1 day' : 'Total';
  @override
  String get eqTotalPayable => 'Total payable';
  @override
  String get eqEditListing => 'Edit listing';
  @override
  String get eqMessageOwner => 'Message owner';
  @override
  String get repMisleading => 'Misleading photos';
  @override
  String get repPriceWrong => 'Price looks wrong';
  @override
  String get repNotAsDescribed => 'Item was not as described';
  @override
  String get repOwnerSilent => 'Owner is unresponsive';
  @override
  String get repDuplicate => 'Duplicate listing';
  @override
  String get repOther => 'Something else';
  @override
  String get repReasonOther => 'Tell us more (optional)';
  @override
  String get repDoneSnack => 'Report sent. Our team will review it.';
  @override
  String get repTitle => 'Report this listing';
  @override
  String get repIntro =>
      'Reports are reviewed by the Neo team. Serious issues may lead to a listing being removed.';
  @override
  String get repExtraField => 'Anything else we should know? (optional)';
  @override
  String get repSubmit => 'Submit report';
  @override
  String get formGallerySnack => 'Could not open the gallery';
  @override
  String get formUrlHintSnack => 'Enter a full http(s) URL';
  @override
  String formSnack(bool isEdit) =>
      isEdit ? 'Listing updated' : 'Listing published';
  @override
  String formTitle(bool isEdit) => isEdit ? 'Edit listing' : 'New listing';
  @override
  String get formOwnerRequiredTitle => 'Owner role required';
  @override
  String get formOwnerRequiredBody =>
      'Switch to the owner role on the My gear tab before publishing a listing.';
  @override
  String get formFieldTitle => 'Title';
  @override
  String get formHintTitle => 'White plastic chairs (50 pcs)';
  @override
  String get formCatLabel => 'Category';
  @override
  String get formPriceLabel => 'Price per day (RWF)';
  @override
  String get formUnitsLabel => 'Units you own';
  @override
  String get formDepositLabel => 'Security deposit per booking (optional)';
  @override
  String get formAreaLabel => 'Collection area';
  @override
  String get formAreaHint => 'Kigali - Nyarugenge';
  @override
  String get formDescLabel => 'Description';
  @override
  String get formDescHint => 'Condition, delivery options, what is included…';
  @override
  String get formAvailButton => 'Manage availability calendar';
  @override
  String formSaveButton(bool isEdit) =>
      isEdit ? 'Save changes' : 'Publish listing';
  @override
  String get formPhotosHead => 'Photos';
  @override
  String get formPhotosSub =>
      'Listings with photos are booked far more often. Add up to six.';
  @override
  String get formUrlField => 'Or paste an image URL';
  @override
  String get formAddUrl => 'Add URL';
  @override
  String get formTakePhoto => 'Take a photo';
  @override
  String get avBlockedSnack => 'Dates blocked';
  @override
  String get avUnblockedSnack => 'Date is bookable again';
  @override
  String get avTitle => 'Availability';
  @override
  String get avAccepting => 'Accepting bookings';
  @override
  String avStateNote(bool live) => live
      ? 'Live — renters can request this item'
      : 'Paused — your listing is hidden from search';
  @override
  String avSwitchTitle(bool live) =>
      live ? 'Your listing is live' : 'Listings paused';
  @override
  String get avTapHint => 'Tap dates to block them';
  @override
  String avBlockButton(int n) => n == 0
      ? 'Select dates to block'
      : 'Block $n date${n == 1 ? '' : 's'}';
  @override
  String get avBlockedHead => 'Blocked dates';
  @override
  String get avNothingBlocked => 'Nothing blocked';
  @override
  String get avNothingBlockedBody => 'Every day is bookable right now.';
  @override
  String avActiveOn(int n) =>
      '$n booking${n == 1 ? '' : 's'} on this date';
  @override
  String get avUnblock => 'Unblock';

  // -------------------------------------------------------------------- auth
  @override
  String get otpVerifyTitle => 'Verify your phone';
  @override
  String get otpDefaultSubtitle =>
      'Enter the code we sent to your phone to continue.';
  @override
  String get otpVerifyCta => 'Verify';
  @override
  String get otpResentSnack => 'A new code has been sent';
  @override
  String authWelcomeSnack(String name) => 'Welcome to Neo, $name!';
  @override
  String get fieldNationalIdOptional => 'National ID (optional)';
  @override
  String get hintIdSixteen => '16 digits';
  @override
  String get hintPasswordSix => 'At least 6 characters';
  @override
  String get authAlreadyHave => 'I already have an account';
  @override
  String get authWelcomeBack => 'Welcome back';
  @override
  String get authSignInSubtitle =>
      'Sign in to rent equipment or manage your listings.';
  @override
  String get fieldPhone => 'Phone number';
  @override
  String get showPassword => 'Show password';
  @override
  String get hidePassword => 'Hide password';
  @override
  String get authForgot => 'Forgot password?';
  @override
  String get authSignIn => 'Sign in';
  @override
  String get authUseOtp => 'Use a one-time code instead';
  @override
  String get authNewToNeo => 'New to Neo?';
  @override
  String get authCreateAccount => 'Create an account';
  @override
  String get authEnterPhoneFirst => 'Enter your phone number first';
  @override
  String get authContinueOtpError => 'Continuing with your one-time code…';
  @override
  String otpSentTo(String phone) =>
      'We sent a 6-digit code to $phone';
  @override
  String get otpDevCode => 'Development code: ';
  @override
  String get otpResend => 'Resend code';
  @override
  String get authRegisterTitle => 'Create your account';
  @override
  String get authRegisterSubtitle =>
      'A phone number is all it takes. Start renting or listing right away.';
  @override
  String get authRegister => 'Create account';
  @override
  String get authHaveAccount => 'Already have an account?';
  @override
  String get authSignInInstead => 'Sign in';
  @override
  String get authOtpTitle => 'Enter your code';
  @override
  String get authOtpSubtitle =>
      'Enter the 6-digit code we sent you to finish signing in.';
  @override
  String get sectionSecurity => 'Security';
  @override
  String get sectionPersonal => 'Personal details';
  @override
  String get sectionId => 'National ID';
  @override
  String get authOtp => 'One-time code';
  @override
  String get authPasswordOption => 'Password (optional)';
  @override
  String get authPasswordOptionalHint =>
      'Set a password only if you want one, otherwise use one-time codes.';
  @override
  String get fieldConfirmPassword => 'Confirm password';
  @override
  String get valPasswordMismatch => 'The passwords do not match';
  @override
  String get authIdHint =>
      'Needed for owner payouts. You can add it later in Profile.';
  @override
  String get authEmailHint => 'For receipts and signup confirmations.';
  @override
  String authRegisterFailed(String message) =>
      'Could not create the account: $message';
  @override
  String get forgotAppbarTitle => 'Reset password';
  @override
  String get forgotScreenIntro =>
      'Enter the phone number on your account and we will send a code to reset your password.';
  @override
  String get forgotNewPasswordHint => 'Choose a new password';
  @override
  String get forgotSendCta => 'Send reset code';
  @override
  String get forgotTitle => 'Reset your password';
  @override
  String get forgotSubtitle =>
      'We will text a one-time code to your phone number.';
  @override
  String get forgotContinue => 'Send code';
  @override
  String get forgotChangeTitle => 'Choose a new password';
  @override
  String get forgotChangeSubtitle =>
      'Use at least 6 characters you do not use anywhere else.';
  @override
  String get fieldNewPasswordShort => 'New password';
  @override
  String get forgotChangedSnack =>
      'Password updated. Please sign in.';

  // -------- Completion: uploads, payments, trust, explore
  @override
  String get photoChooseSource => 'Add a photo';
  @override
  String get photoTakeNew => 'Take a photo';
  @override
  String get photoFromGallery => 'Choose from gallery';
  @override
  String get photoUploading => 'Uploading…';
  @override
  String get photoUploadFailed => 'Could not upload the photo. Try again.';
  @override
  String get photoCover => 'Cover';
  @override
  String get formPhotosTitle => 'Photos';
  @override
  String get formPhotosHint => 'Listings with clear photos get booked far more often. Add up to six — the first one is the cover.';
  @override
  String get formPhotosWaitUpload => 'Wait for photos to finish uploading';
  @override
  String get avatarChange => 'Change photo';
  @override
  String get avatarRemove => 'Remove photo';
  @override
  String get avatarUpdated => 'Profile photo updated';
  @override
  String get avatarRemoved => 'Profile photo removed';
  @override
  String get payHistoryTitle => 'Payments';
  @override
  String get payHistorySubtitle => 'Rentals, payouts, boosts and withdrawals';
  @override
  String get payHistoryEmptyTitle => 'No payments yet';
  @override
  String get payHistoryEmptyBody => 'When you pay for a rental, boost a listing or receive a payout, it shows up here.';
  @override
  String get payTotalPaid => 'Paid';
  @override
  String get payTotalPending => 'Pending';
  @override
  String get payTxCount => 'Transactions';
  @override
  String get txCommission => 'Platform commission';
  @override
  String get txPayout => 'Rental payout';
  @override
  String get txBoost => 'Listing boost';
  @override
  String get txRental => 'Rental payment';
  @override
  String get txWithdrawal => 'Withdrawal';
  @override
  String get txRefund => 'Refund';
  @override
  String get payRef => 'Reference';
  @override
  String get reportsTitle => 'My reports';
  @override
  String get reportsEmptyTitle => 'No reports';
  @override
  String get reportsEmptyBody => 'Reports you file about listings, users or reviews appear here with their status.';
  @override
  String get targetEquipment => 'Listing';
  @override
  String get targetUser => 'User';
  @override
  String get targetReview => 'Review';
  @override
  String get targetMessage => 'Message';
  @override
  String get statusOpen => 'Open';
  @override
  String get statusInReview => 'In review';
  @override
  String get statusResolved => 'Resolved';
  @override
  String get statusDismissed => 'Dismissed';
  @override
  String get statusClosed => 'Closed';
  @override
  String get disputeTitle => 'Dispute';
  @override
  String get disputeView => 'View dispute';
  @override
  String get disputeReason => 'What went wrong';
  @override
  String get disputeResponse => 'Response';
  @override
  String get disputeResolution => 'Neo’s decision';
  @override
  String get disputeNoResponse => 'Waiting for the other party to respond.';
  @override
  String get disputeAwaitingDecision => 'Our team is reviewing both sides. Funds stay on hold until a decision is made.';
  @override
  String get disputeRespondHint => 'Explain your side clearly and calmly — our team reads both accounts before deciding.';
  @override
  String get disputeRespondField => 'Your response';
  @override
  String get disputeRespondSubmit => 'Send response';
  @override
  String get disputeResponded => 'Response sent';
  @override
  String get disputeStepOpened => 'Dispute opened';
  @override
  String get disputeStepResponse => 'Response received';
  @override
  String get disputeStepDecision => 'Decision by Neo';
  @override
  String get disputeForBooking => 'Booking';
  @override
  String get explorePopular => 'Popular right now';
  @override
  String get exploreNearby => 'Near you';
  @override
  String get exploreNearbySub => 'Around Kigali';
  @override
  String get actPayments => 'Payments';
  @override
  String get actReports => 'My reports';
  @override
  String get actAdmin => 'Admin console';
  @override
  String get actAdminSub => 'Moderate users, listings, money and disputes';
  @override
  String get navUnreadHint => 'unread';
  @override
  String caseStatus(String wire) =>
      switch (wire) { 'IN_REVIEW' => statusInReview, 'RESOLVED' => statusResolved, 'DISMISSED' => statusDismissed, 'CLOSED' => statusClosed, _ => statusOpen };
  @override
  String reportTarget(String wire) =>
      switch (wire) { 'USER' => targetUser, 'REVIEW' => targetReview, 'MESSAGE' => targetMessage, _ => targetEquipment };

  // -------- Admin console
  @override
  String get adminTitle => 'Admin console';
  @override
  String get adminOverview => 'Overview';
  @override
  String get adminUsers => 'Users';
  @override
  String get adminListings => 'Listings';
  @override
  String get adminMoney => 'Money';
  @override
  String get adminTrust => 'Trust';
  @override
  String get adminBookings => 'Bookings';
  @override
  String get adminPending => 'Pending';
  @override
  String get adminCompleted => 'Completed';
  @override
  String get adminRevenue => 'Platform revenue';
  @override
  String get adminRevenueSub => 'Commission and boosts collected';
  @override
  String get adminOpenReports => 'Open reports';
  @override
  String get adminOpenDisputes => 'Open disputes';
  @override
  String get adminLast30 => 'Last 30 days';
  @override
  String get adminNewUsers => 'New users';
  @override
  String get adminNewBookings => 'New bookings';
  @override
  String get adminTopListings => 'Top listings';
  @override
  String get adminNeedsAttention => 'Needs attention';
  @override
  String get adminAllClear => 'All clear — nothing waiting for review.';
  @override
  String get adminVerify => 'Verify';
  @override
  String get adminVerified => 'Verified';
  @override
  String get adminBan => 'Ban';
  @override
  String get adminUnban => 'Unban';
  @override
  String get adminBanned => 'Banned';
  @override
  String get adminBanConfirmTitle => 'Ban this user?';
  @override
  String get adminBanConfirmBody => 'They will be signed out and can no longer book or list equipment until unbanned.';
  @override
  String get adminApprove => 'Approve';
  @override
  String get adminReject => 'Reject';
  @override
  String get adminApproved => 'Approved';
  @override
  String get adminAwaitingApproval => 'Awaiting approval';
  @override
  String get adminTransactions => 'Transactions';
  @override
  String get adminReviews => 'Reviews';
  @override
  String get adminDeleteReview => 'Delete review';
  @override
  String get adminDeleteReviewBody => 'This permanently removes the review and recalculates ratings.';
  @override
  String get adminReports => 'Reports';
  @override
  String get adminDisputes => 'Disputes';
  @override
  String get adminResolve => 'Resolve';
  @override
  String get adminDismiss => 'Dismiss';
  @override
  String get adminCloseCase => 'Close';
  @override
  String get adminNoteField => 'Note (optional)';
  @override
  String get adminDecisionField => 'Decision shared with both parties';
  @override
  String get adminDecisionRequired => 'Write the decision first';
  @override
  String get adminSaved => 'Saved';
  @override
  String get adminEmpty => 'Nothing here yet';
  @override
  String get adminEmptyBody => 'New items will appear here as people use Neo.';
  @override
  String get adminRenter => 'Renter';
  @override
  String get adminOwner => 'Owner';
  @override
  String adminReportedBy(String name) =>
      'Reported by $name';
  @override
  String adminOpenedBy(String name) =>
      'Opened by $name';
  @override
  String adminBy(String name) =>
      'by $name';

  // -------- Nearby map
  @override
  String get mapTitle => 'Nearby map';
  @override
  String get mapOpen => 'Map';
  @override
  String get mapLayerAll => 'All';
  @override
  String get mapLayerLenders => 'Lenders';
  @override
  String get mapLayerBorrowers => 'Borrowers';
  @override
  String get mapLender => 'Lender';
  @override
  String get mapBorrower => 'Borrower';
  @override
  String get mapSearchArea => 'Search this area';
  @override
  String get mapRecenter => 'My location';
  @override
  String get mapRadius => 'Radius';
  @override
  String get mapLoading => 'Finding people near you…';
  @override
  String get mapEmptyTitle => 'No one here yet';
  @override
  String get mapEmptyBody => 'Try a wider radius or move the map to another area.';
  @override
  String get mapUsingDefault => 'Showing Kigali. Turn on location to see who is near you.';
  @override
  String get mapLocationOff => 'Location services are off';
  @override
  String get mapLocationDenied => 'Location permission was denied';
  @override
  String get mapOpenSettings => 'Settings';
  @override
  String get mapFromPrice => 'from';
  @override
  String get mapViewProfile => 'Profile';
  @override
  String get mapMessage => 'Message';
  @override
  String get mapLookingFor => 'Looking for';
  @override
  String get mapApproxArea => 'Approximate area';
  @override
  String get mapMeTitle => 'Show me on the map';
  @override
  String get mapMeSubtitle => 'Let nearby lenders find you when you need equipment';
  @override
  String get mapMeSwitch => 'Visible to lenders nearby';
  @override
  String get mapMePrivacy => 'Others only see an approximate area (about 1 km), never your exact spot. You disappear automatically after 30 days unless you refresh your location.';
  @override
  String get mapMeNote => 'What do you need? (optional)';
  @override
  String get mapMeNoteHint => 'e.g. 100 chairs and a tent for Saturday';
  @override
  String get mapMeArea => 'Area name (optional)';
  @override
  String get mapMeAreaHint => 'e.g. Kigali - Remera';
  @override
  String get mapMeUseLocation => 'Use my current location';
  @override
  String get mapMeLocationSet => 'Location saved';
  @override
  String get mapMeNoLocation => 'No location shared yet';
  @override
  String get mapMeRemove => 'Remove me from the map';
  @override
  String get mapMeSaved => 'Map settings saved';
  @override
  String get mapMeRemoved => 'Your location was deleted';
  @override
  String get mapMeYou => 'You';
  @override
  String get mapMeVisible => 'You are visible';
  @override
  String get mapMeHidden => 'You are hidden';
  @override
  String get mapAttribution => 'Map data';
  @override
  String mapKmAway(double km) =>
      '${km < 1 ? '<1' : km.toStringAsFixed(km < 10 ? 1 : 0)} km away';
  @override
  String mapListings(int n) =>
      n == 1 ? '1 listing' : '$n listings';
  @override
  String mapRadiusKm(int km) =>
      '$km km';
  @override
  String mapActive(String when) =>
      'Active $when';
}

/// Kinyarwanda translations.
class SRw implements S {
  const SRw();

  @override
  String get appTitle => 'Neo — Kurenda ibikoresho by\'ibirori';
  @override
  String get momoShort => 'MoMo';
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
  String get ratingNew => 'Gishya';
  @override
  String get errorCouldNotLoad => 'Kuzana byanze';
  @override
  String get errorTryAgain => 'Gerageza';
  @override
  String get photoNoPhotoYet => 'Nta shusho irahari';
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
      'Intebe, ameza, amahema, amajwi, ingufu na Deko — biva ku bafite bemejwe, mu Kigali no kure ya Kigali.';
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
      'Abafite bashyiraho intebe, amahema, amajwi no za generator kuri Neo, kandi bagahabwa amafaranga ku myanya yuzuye yose. Wisigaza 90% — dufata 10%.';
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
      'Ishyura ikiguzi gito ngo ugaragare mbere kuri gushakisha mu minsi mike.';
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
  String get prefsLanguageKinyarwanda => 'Kinyarwanda';
  @override
  String get supportSectionTitle => 'Ubufasha';
  @override
  String get supportIntro =>
      'Ukeneye ubufasha? Timu ya Neo isubiza amahamagara kuri nimero za MoMo, kuwa mbere kugera kuwa gatandatu, 8:00–18:00.';
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

  // -------------------------------------------------------------- validators
  @override
  String get valPhoneEmpty => 'Andika nimero ya telefone yawe';
  @override
  String get valPhonePattern =>
      'Andika nimero ikwiye y\'u Rwanda, nk.\' 0780000000';
  @override
  String get valFullNameEmpty => 'Andika izina ryuzuye';
  @override
  String get valFullNameShort => 'Izina rigufi cyane';
  @override
  String get valEmailInvalid => 'Andika imeri ikwiye';
  @override
  String get valPasswordEmpty => 'Andika ijambobanga';
  @override
  String get valPasswordShort => 'Ibiharika 6 nibura';
  @override
  String get valIdEmpty => 'Andika ID yawe ya kavukire';
  @override
  String get valIdPattern => 'ID ya kavukire ifite ibiharika 16';
  @override
  String get valOtpEmpty => 'Andika kode, imibare 6';
  @override
  String get valOtpPattern => 'Kode ni imibare 6';
  @override
  String get valTitleEmpty => 'Andika izina ry\'ibikoresho';
  @override
  String get valTitleShort => 'Ibiharika 4 nibura';
  @override
  String get valDescriptionLong => 'Munsi y\'ibiharika 2000';
  @override
  String get valLocationEmpty => 'Handite ibikoresho he?';
  @override
  String get valQuantityNumber => 'Andika umubare';
  @override
  String get valQuantityMin => 'Nibura 1';
  @override
  String valQuantityMax(int max) => 'Birarengeje $max';
  @override
  String get valPriceNumber => 'Andika igiciro mu RWF';
  @override
  String get valPriceZero => 'Igiciro kirengeje 0';
  @override
  String get valPriceRange => 'Igiciro ridakwiye';
  @override
  String get valFieldRequired => 'Ibi ni ngombwa';
  @override
  String get sessionExpired => 'Amasezinkuru yaranze — winjire ubwa nyuma.';

  // --------------------------------------------------------------- explore
  @override
  String get greetingMorning => 'Mwaramutse';
  @override
  String get greetingAfternoon => 'Mwiriwe';
  @override
  String get greetingEvening => 'Mwiriwe';
  @override
  String get exploreHeadline => 'Shakisha ibikoresho by\'ibirori';
  @override
  String get exploreSearchHint => 'Intebe, amahema, amajwi…';
  @override
  String get chipAll => 'Byose';
  @override
  String itemCount(int count) => 'Ibintu $count';
  @override
  String get filterPriceChip => 'Igiciro';
  @override
  String get commonClear => 'Gukuraho';
  @override
  String get emptyNoMatchesTitle => 'Nta bihuza';
  @override
  String get emptyNoMatchesBody => 'Gera ubundi bwoko, ahandi cyangwa igiciro kindi.';
  @override
  String get emptyNoEquipmentTitle => 'Nta bikoresho birahari';
  @override
  String get emptyNoEquipmentBody => 'Eka mbere yese ku Neo: intebe, ameza cyangwa amajwi.';
  @override
  String get emptyClearFilters => 'Kuraho ibihitamo';
  @override
  String get endOfList => 'Ibi ni byose byo kuri iyi rutonde';
  @override
  String get catChairs => 'Intebe';
  @override
  String get catTables => 'Ameza';
  @override
  String get catTents => 'Amahema';
  @override
  String get catSpeakers => 'Amajwi';
  @override
  String get catLights => 'Urumuri';
  @override
  String get catCoolers => 'Ifrigo';
  @override
  String get catGenerators => 'Ingufu';
  @override
  String get catDecor => 'Deko';
  @override
  String get catOther => 'Ibindi';
  @override
  String get filterTitle => 'Imyanya yo guhitamo';
  @override
  String get filterWhere => 'Hehe';
  @override
  String get filterSectorLabel => 'Umurenge cyangwa akarere';
  @override
  String get filterDailyPrice => 'Igiciro cya munsi (RWF)';
  @override
  String get filterAvailableOn => 'Birahari ku';
  @override
  String get filterAnyDate => 'Itariki iyo ari yo';
  @override
  String get filterAnyPrice => 'Igiciro iyo ari cyo';
  @override
  String get filterShowResults => 'Kugaragaza ibisubizo';
  @override
  String get filterReset => 'Kugarura';
  @override
  String get filterDateHelp => 'Ukeneye ryari?';
  @override
  String get tooltipNotifications => 'Amatangazo';
  @override
  String get badgeBoosted => 'Kwiyamamaza';
  @override
  String get badgeUnavailable => 'Ntibirahari';
  @override
  String get perDay => '/umunsi';

  // ------------------------------------------------------------------ enums
  @override
  String get catChairsFull => 'Intebe';
  @override
  String get catTablesFull => 'Ameza';
  @override
  String get catTentsFull => 'Amahema';
  @override
  String get catSpeakersFull => 'Amajwi';
  @override
  String get catLightsFull => 'Urumuri';
  @override
  String get catCoolersFull => 'Ifrigo';
  @override
  String get catGeneratorsFull => 'Ingufu';
  @override
  String get catDecorFull => 'Deko';
  @override
  String get catOtherFull => 'Ibindi';
  @override
  String get statusPending => 'Birategereza';
  @override
  String get statusAccepted => 'Yemejwe';
  @override
  String get statusRejected => 'Yanze';
  @override
  String get statusCancelled => 'Byahagaritswe';
  @override
  String get statusOngoing => 'Irakorwa';
  @override
  String get statusCompleted => 'Byarangiye';
  @override
  String get statusDisputed => 'Hari impaka';
  @override
  String get hintPending => 'Turindira igisubizo cy\'umufite';
  @override
  String get hintAccepted => 'Byemejwe — tunganya itariki n\'aho batangwa ibikoresho';
  @override
  String get hintRejected => 'Umufite yanze isaba.';
  @override
  String get hintCancelled => 'Umwanya wahagaritswe.';
  @override
  String get hintOngoing => 'Kurenda kiri hagati.';
  @override
  String get hintCompleted => 'Kurenda kwarangiye.';
  @override
  String get hintDisputed => 'Impaka iri mu isuzuma.';
  @override
  String get paymentPending => 'Birategereza';
  @override
  String get paymentPaid => 'Byishyujwe';
  @override
  String get paymentRefunded => 'Byagarutswe';
  @override
  String get paymentFailed => 'Byanze';
  @override
  String get rentalPayout => 'Ibishyuro bya kurenda';

  // ----------------------------------------------------------- booking flow
  @override
  String get flowDates => 'Amatariki';
  @override
  String get flowDatesSub => 'Ukeneye ryari?';
  @override
  String get flowQuantity => 'Umubare';
  @override
  String get flowQuantitySub => 'Ibikoresho bingahe?';
  @override
  String get flowSummary => 'Incamake';
  @override
  String get flowSummarySub => 'Kagenza ibyanditswe';
  @override
  String get flowPayment => 'Kwishyura';
  @override
  String get flowPaymentSub => 'Shyura ukoresheje Mobile Money';
  @override
  String flowRequestSent(String owner) => 'Isaba ryabweheretse $owner.';
  @override
  String get flowOwnerFallback => 'umufite';
  @override
  String get flowPaymentConfirmed => 'Kwishyura cyemejwe — umufite yamenyeshejwe.';
  @override
  String get flowTitle => 'Kusaba gukodesha';
  @override
  String get calMonth => 'Ukwezi';
  @override
  String get flowBlockedRange => 'Igihe cyatoranya kirimo umunsi udafungura';
  @override
  String flowBlockedByOwner(int n) => 'Iminsi $n yafunzwe n\'umufite.';
  @override
  String get flowOwnerNoteLabel => 'Ubutumwa ku mufite (ntibyangombwa)';
  @override
  String get flowOwnerNoteHint => 'Ubwoko bw\'ibirori, impano, isaha…';
  @override
  String get flowUnitsNeeded => 'Ubwinshi bukenewe';
  @override
  String get flowEstimatedTotal => 'Igiteranyo kigerejwe';
  @override
  String get flowOwnListingTitle => 'Iyi ni ivyawe';
  @override
  String get flowOwnListingMessage =>
      'Nta gukorenda ibyawe. Kugena kuri tab la \u201cIbikoresho byanjye\u201d.';
  @override
  String flowUnitCount(int n) => 'Ibikoresho $n';
  @override
  String flowDayCount(int n) => 'Iminsi $n';
  @override
  String get flowSubtotal => 'Igiteranyo kurenda';
  @override
  String get flowPlatformFee => 'Amatangazo ya Neo (10%)';
  @override
  String get flowDeposit => 'Amafaranga agarurwa (ahanditse)';
  @override
  String get flowYouPayNow => 'Ugiye kwishyura';
  @override
  String get flowPayNothingYet =>
      'Nta cyakwishyura ubu. Umufite asoma isaba ku mbere — '
      'wishyura nyuma y\'uko yemeje.';
  @override
  String flowMessageOwner(String name) => 'Umubwire $name';
  @override
  String get flowAskPickup => 'Gusaba itangira ukoresheje ukorende';
  @override
  String get flowNoRequestTitle => 'Nta saba ryawe';
  @override
  String get flowNoRequestBody =>
      'Subira kuri incamake, ohereze isaba nyuma.';
  @override
  String get flowPaymentCompleteTitle => 'Kwishyura byarangiye';
  @override
  String flowPaymentCompleteBody(String total, String payout) =>
      'Wishyuye $total. Umufite ahisha $payout na Neo ifata 10%.';
  @override
  String get flowWaitingOwner => 'Turindira umufite';
  @override
  String flowStatusNote(String status) =>
      'Imiterere y\'isaba ni $status. Uzamenyeshwa iyo umufite asubiza; '
      'kwishyura kozwa uruhushi mu buryo.';
  @override
  String get flowMessageOwnerCta => 'Umubwire umufite';
  @override
  String get flowAmountDue => 'Amafaranga asigaye';
  @override
  String get flowPayWith => 'Shyura';
  @override
  String get momoName => 'MTN Rwanda';
  @override
  String get airtelName => 'Airtel Rwanda';
  @override
  String get flowMomoNumber => 'Nimero ya Mobile Money';
  @override
  String get flowChooseMethod => 'Hitamo uburyo bwo kwishyura';
  @override
  String flowPayTotal(String total) => 'Shyura $total';
  @override
  String get flowClose => 'Funga';
  @override
  String get flowBack => 'Subira inyuma';
  @override
  String get flowContinue => 'Komeza';
  @override
  String get flowSendRequest => 'Ohereza isaba';
  @override
  String get flowContinuePayment => 'Komeza ku kwishyura';
  @override

  @override
  String get roleRenter => 'Umurendi';
  @override
  String get roleOwner => 'Umufite';
  @override
  String get roleAdmin => 'Umuyobozi';
  @override
  String get bkTitle => 'Imyanya';
  @override
  String get bkTabRenting => 'Kurenda';
  @override
  String get bkTabMine => 'Ibikoresho byanjye';
  @override
  String get bkChipAll => 'Byose';
  @override
  String get bkEmptyMine => 'Nta myanya irahari';
  @override
  String get bkEmptyOwned => 'Nta bisabwa birahari';
  @override
  String get bkEmptyMineBody => 'Shakisha ibikoresho ku isoko, ohereze isaba rya mbere.';
  @override
  String get bkEmptyOwnedBody => 'Iyo umurendi agisaba ikintu cyawe, kiragaruka hano.';
  @override
  String get bkBrowseCta => 'Gushakisha ibikoresho';
  @override
  String get bkEndList => 'Nta myanya zikurikira';
  @override
  String get bkFallbackTitle => 'Umwanya';
  @override
  String bkPaidInfo(String payout) => 'Byishyujwe · umufite ahabwa $payout';
  @override
  String get bkPaymentPending => 'Kwishyura birategereza';
  @override
  String get bkDecline => 'Yanze';
  @override
  String get bkAccept => 'Emeza';
  @override
  String get bkPayNow => 'Shyura ubu';
  @override
  String get bdPaymentConfirmed => 'Kwishyura cyemejwe';
  @override
  String bdSnack(String status) => 'Umwanya: $status';
  @override
  String get bdExtendHelp => 'Itariki nyashya yo kurangira';
  @override
  String get bdNotFound => 'Ntabwo kibone';
  @override
  String get bdTitle => 'Umwanya';
  @override
  String get bdTimeline => 'Urukurikirane';
  @override
  String get bdTotal => 'Igiteranyo kurenda';
  @override
  String get bdDepositRecorded => 'Ingwate (yanditse)';
  @override
  String get bdYouReceive => 'Uzahabwa';
  @override
  String get bdOwnerReceives => 'Umufite ahabwa';
  @override
  String get bdNoActivityTitle => 'Nta bikorwa birahari';
  @override
  String get bdNoActivityBody => 'Ibihinduka biragaruka hano.';
  @override
  String get bdActorSystem => 'Sisitemu';
  @override
  String bdMessageRenter(String name) => 'Umubwire $name';
  @override
  String bdMessageOwner(String name) => 'Umubwire $name';
  @override
  String get bdAcceptRequest => 'Emeza isaba';
  @override
  String get bdStart => 'Tangira kurenda';
  @override
  String get bdExtend => 'Rimbuka umwanya';
  @override
  String get bdComplete => 'Rangamura byarangiye';
  @override
  String get bdReview => 'Andika igitekerezo';
  @override
  String get bdReport => 'Menya imbazo';
  @override
  String get bdCancel => 'Hagarika umwanya';
  @override
  String get bdCancelTitle => 'Hagarika umwanya?';
  @override
  String get bdCancelBody => 'Ibi ntibigaruka inyuma. Gera ku bandi mbere.';
  @override
  String get bdDisputeBody => 'Impaka ihagaraza umwanya; ikipe ya Neo izasuzuma.';
  @override
  String get bdDisputeField => 'Ikibazo ni iki?';
  @override
  String get bdDisputeSubmit => 'Fungura impaka';
  @override
  String get bdDisputeSnack => 'Impaka ifunguwe. Tuzahugira na we.';

  // ------------------------------------------------------------ equipment
  @override
  String get eqLoadingListing => 'Kurikuramo…';
  @override
  String get eqNotFound => 'Ntabwo kibone';
  @override
  String get eqPerDay => 'Umukunda ku munsi';
  @override
  String get eqAvailable => 'Ibikoresho birahari';
  @override
  String eqStatusOpen(bool open) => open ? 'Birakodesha' : 'Birahagaritswe';
  @override
  String eqDepositInfo(String amount) =>
      'Ingwate ya $amount yanditse kuri umwanya.';
  @override
  String get eqAbout => 'Ibinyujije kuri ibi';
  @override
  String get eqAvailabilityHead => 'Umwanya urahari';
  @override
  String get eqAvailabilitySub =>
      'Hitamo amatariki yawe. Iminsi ifunze ntikoreshe';
  @override
  String get eqFormerOwnerTag => 'Umufite mushya';
  @override
  String get eqShareTotal => 'Hitamo amatariki kuri kalendari ubone igiteranyo.';
  @override
  String get eqRangeUnavailable => 'Igihe cyawawe kirimo umunsi ufunze';
  @override
  String get eqDayUnavailable => 'Umunsi uwo ntushobora kunyagwa';
  @override
  String eqTotalFor(int days) => days == 1 ? 'Igiteranyo cya munsi umwe' : 'Igiteranyo';
  @override
  String get eqTotalPayable => 'Amafaranga yose zo kwishyura';
  @override
  String get eqEditListing => 'Kuhindura ibyanditswe';
  @override
  String get eqMessageOwner => 'Umubwire umufite';
  @override
  String get repMisleading => 'Amademe ari mabi';
  @override
  String get repPriceWrong => 'Igiciro kimeze nta kuri kiterevye';
  @override
  String get repNotAsDescribed => 'Ikintu ntakiri igihe cyanditse';
  @override
  String get repOwnerSilent => 'Umufite ntayagira igisubizo';
  @override
  String get repDuplicate => 'Ibiri gusa';
  @override
  String get repOther => 'Ikintu kindi';
  @override
  String get repReasonOther => 'Itanga isobanuro (ntibyangombwa)';
  @override
  String get repDoneSnack => 'Icyarimo cyoherejwe. Ikipaza ya Neo kizasuzuma.';
  @override
  String get repTitle => 'Rapora ibyanditswe';
  @override
  String get repIntro =>
      'Ikipe ya Neo isuzuma rapora. Ibibazo bikomeye birashobora kuzana kuryaha ibyanditswe.';
  @override
  String get repExtraField => 'Ikintu kindi dukoresheze? (ntibyangombwa)';
  @override
  String get repSubmit => 'Ohereza rapora';
  @override
  String get formGallerySnack => 'Ntibyeganza gusinga ishusho';
  @override
  String get formUrlHintSnack => 'Andika URL nyirizina http(s)';
  @override
  String formSnack(bool isEdit) =>
      isEdit ? 'Ibyanditswe byahinduwe' : 'Ibyanditswe byatangijwe';
  @override
  String formTitle(bool isEdit) =>
      isEdit ? 'Kuhindura ibyanditswe' : 'Ibyanditswe bishya';
  @override
  String get formOwnerRequiredTitle => 'Ubifite ni umbishiwa';
  @override
  String get formOwnerRequiredBody =>
      'Hindura ku mufite kuri tab ya Ibikoresho byanjye mbere.';
  @override
  String get formFieldTitle => 'Izina';
  @override
  String get formHintTitle => 'Intebe za pesa zera (50)';
  @override
  String get formCatLabel => 'Ubwoko';
  @override
  String get formPriceLabel => 'Igiciro cya munsi (RWF)';
  @override
  String get formUnitsLabel => 'Ibikoresho uifite';
  @override
  String get formDepositLabel => 'Ingwate ku mwanya umwe (ntibyangombwa)';
  @override
  String get formAreaLabel => 'Ahantu abantu bakuva';
  @override
  String get formAreaHint => 'Kigali - Nyarugenge';
  @override
  String get formDescLabel => 'Ibisobanuro';
  @override
  String get formDescHint => 'Uko bimeze, impano, ibiri muri…';
  @override
  String get formAvailButton => 'Tunganya kalendari y\'umwanya';
  @override
  String formSaveButton(bool isEdit) =>
      isEdit ? 'Bika impinduka' : 'Tangaza ibyanditswe';
  @override
  String get formPhotosHead => 'Amademe';
  @override
  String get formPhotosSub =>
      'Ibyanditswe bifite amademe bikorwa cyane. Shyira kuri 6.';
  @override
  String get formUrlField => 'Cyangwa shinnye URL y\'ishusho';
  @override
  String get formAddUrl => 'Ongera URL';
  @override
  String get formTakePhoto => 'Fata ifoto';
  @override
  String get avBlockedSnack => 'Amatariki yafunze';
  @override
  String get avUnblockedSnack => 'Umunsi wagarutse';
  @override
  @override
  String get avTitle => 'Umwanya urahari';
  @override
  String get avAccepting => 'Amabwiriza ahari';
  @override
  String avStateNote(bool live) => live
      ? 'Birakorwa — abarenda bashobora kugisaba'
      : 'Birahagaritswe — ibyawe bikubaa mu ishakiro';
  @override
  String avSwitchTitle(bool live) =>
      live ? 'Ibyawe birakorwa' : 'Ibyanditswe byahagaritswe';
  @override
  String get avTapHint => 'Kanda amatariki uyafunze';
  @override
  String avBlockButton(int n) => n == 0
      ? 'Hitamo amatariki gurufunze'
      : 'Funga amatariki $n';
  @override
  String get avBlockedHead => 'Amatariki yafunze';
  @override
  String get avNothingBlocked => 'Nta kindi cyafunze';
  @override
  String get avNothingBlockedBody => 'Iminsi yose irahashya ubu.';
  @override
  String avActiveOn(int n) => 'Umwanya $n kuri itariki';
  @override
  String get avUnblock => 'Fungura';
  // -------------------------------------------------------------------- auth

  @override
  String get otpVerifyTitle => 'Emeza telefone yawe';
  @override
  String get otpDefaultSubtitle =>
      'Andika kode twakoriherera kuri telefone yawe, ugereho.';
  @override
  String get otpVerifyCta => 'Emeza';
  @override
  String get otpResentSnack => 'Ongera kuha kode';
  @override
  String authWelcomeSnack(String name) => 'Murakaza neza kuri Neo, $name!';
  @override
  String get fieldNationalIdOptional => 'ID ya kavukire (ntibyangombwa)';
  @override
  String get hintIdSixteen => 'Imibare 16';
  @override
  String get hintPasswordSix => 'Ibiharika 6 nibura';
  @override
  String get authAlreadyHave => 'Usanzwe wafite konti';
  @override
  String get authWelcomeBack => 'Murakaza neza';
  @override
  String get authSignInSubtitle =>
      'Injira kurenda ibikoresho cyangwa gukurikira ibyo washizweho.';
  @override
  String get fieldPhone => 'Nimero ya telefone';
  @override
  String get showPassword => 'Garagaza ijambobanga';
  @override
  String get hidePassword => 'Hisha ijambobanga';
  @override
  String get authForgot => 'Wibagiwe ijambobanga?';
  @override
  String get authSignIn => 'Injira';
  @override
  String get authUseOtp => 'Komeza ufite kode imwe';
  @override
  String get authNewToNeo => 'Nshya kuri Neo?';
  @override
  String get authCreateAccount => 'Fungura konti';
  @override
  String get authEnterPhoneFirst => 'Banza wandike nimero ya telefone';
  @override
  String get authContinueOtpError => 'Komeza ku cyiciro cya kode';
  @override
  String otpSentTo(String phone) => 'Twohereje kode ya imibare 6 kuri $phone';
  @override
  String get otpDevCode => 'Kode yo ku kugerageza: ';
  @override
  String get otpResend => 'Ongera wohereze kode';
  @override
  String get authRegisterTitle => 'Fungura konti yawe';
  @override
  String get authRegisterSubtitle =>
      'Kurenda acetse kuri nimero ya telefone yawe. Ishyira ID nyuma uhinduke ibikoresho byawe.';
  @override
  String get authRegister => 'Fungura konti';
  @override
  String get authHaveAccount => 'Usanzwe wafite konti?';
  @override
  String get authSignInInstead => 'Injira';
  @override
  String get authOtpTitle => 'Andika kode yawe';
  @override
  String get authOtpSubtitle =>
      'Andika kode ya imibare 6 wakuye kuri SMS.';
  @override
  String get sectionSecurity => 'Umutekano';
  @override
  String get sectionPersonal => 'Amakuru yihariye';
  @override
  String get sectionId => 'ID ya kavukire';
  @override
  String get authOtp => 'Kode';
  @override
  String get authPasswordOption => 'Ijambobanga (ntibyangombwa)';
  @override
  String get authPasswordOptionalHint =>
      'Ijambobanga ni ihitamo — birumwe nta kibazo; urashobora gukoresha kode.';
  @override
  String get fieldConfirmPassword => 'Emeza ijambobanga';
  @override
  String get valPasswordMismatch => 'Amajambobanga atahuye';
  @override
  String get authIdHint =>
      'Ngombwa ku bishyura by\'abafite. Urashobora kubiyongera nyuma kuri Umwirondoro.';
  @override
  String get authEmailHint =>
      'Kubona iby\'ishyuriro no kwemeza konti.';
  @override
  String authRegisterFailed(String message) =>
      'Fungura konti byanze: $message';
  @override
  String get forgotAppbarTitle => 'Hindura ijambobanga';
  @override
  String get forgotScreenIntro =>
      'Andika nimero ya telefone ya konti yawe — twaza kohereza kode yo guhindura ijambobanga.';
  @override
  String get forgotNewPasswordHint => 'Hitamo ijambobanga rishya';
  @override
  String get forgotSendCta => 'Ohereza kode yo guhindura';
  @override
  String get forgotTitle => 'Hindura ijambobanga ryawe';
  @override
  String get forgotSubtitle =>
      'Twaza kohereza kode kuri telefone yawe.';
  @override
  String get forgotContinue => 'Ohereza kode';
  @override
  String get forgotChangeTitle => 'Hitamo ijambobanga rishya';
  @override
  String get forgotChangeSubtitle =>
      'Andika ibiharika nibura 6 utakoresha ahandi.';
  @override
  String get fieldNewPasswordShort => 'Ijambobanga rishya';
  @override
  String get forgotChangedSnack =>
      'Ijambobanga ryahinduwe. Injira ubu.';

  // -------- Completion: uploads, payments, trust, explore
  @override
  String get photoChooseSource => 'Ongeraho ifoto';
  @override
  String get photoTakeNew => 'Fata ifoto';
  @override
  String get photoFromGallery => 'Hitamo muri galeri';
  @override
  String get photoUploading => 'Biroherezwa…';
  @override
  String get photoUploadFailed => 'Ntibyakunze kohereza ifoto. Ongera ugerageze.';
  @override
  String get photoCover => 'Iy’imbere';
  @override
  String get formPhotosTitle => 'Amafoto';
  @override
  String get formPhotosHint => 'Ibikoresho bifite amafoto meza bikodeshwa cyane. Ongeraho kugeza kuri atandatu — irya mbere ni iy’imbere.';
  @override
  String get formPhotosWaitUpload => 'Tegereza amafoto arangize koherezwa';
  @override
  String get avatarChange => 'Hindura ifoto';
  @override
  String get avatarRemove => 'Kuraho ifoto';
  @override
  String get avatarUpdated => 'Ifoto yawe yavuguruwe';
  @override
  String get avatarRemoved => 'Ifoto yawe yakuweho';
  @override
  String get payHistoryTitle => 'Ubwishyu';
  @override
  String get payHistorySubtitle => 'Ubukode, amafaranga wahawe, kwamamaza no kubikuza';
  @override
  String get payHistoryEmptyTitle => 'Nta bwishyu buraba';
  @override
  String get payHistoryEmptyBody => 'Iyo wishyuye ubukode, ukamamaza igikoresho cyangwa ukakira amafaranga, bigaragara hano.';
  @override
  String get payTotalPaid => 'Byishyuwe';
  @override
  String get payTotalPending => 'Bitegereje';
  @override
  String get payTxCount => 'Ibikorwa';
  @override
  String get txCommission => 'Komisiyo ya Neo';
  @override
  String get txPayout => 'Amafaranga y’ubukode';
  @override
  String get txBoost => 'Kwamamaza igikoresho';
  @override
  String get txRental => 'Kwishyura ubukode';
  @override
  String get txWithdrawal => 'Kubikuza';
  @override
  String get txRefund => 'Gusubizwa amafaranga';
  @override
  String get payRef => 'Indango';
  @override
  String get reportsTitle => 'Raporo zanjye';
  @override
  String get reportsEmptyTitle => 'Nta raporo';
  @override
  String get reportsEmptyBody => 'Raporo watanze ku bikoresho, abakoresha cyangwa ibitekerezo zigaragara hano n’aho zigeze.';
  @override
  String get targetEquipment => 'Igikoresho';
  @override
  String get targetUser => 'Umukoresha';
  @override
  String get targetReview => 'Igitekerezo';
  @override
  String get targetMessage => 'Ubutumwa';
  @override
  String get statusOpen => 'Birafunguye';
  @override
  String get statusInReview => 'Birasuzumwa';
  @override
  String get statusResolved => 'Byakemutse';
  @override
  String get statusDismissed => 'Byanzwe';
  @override
  String get statusClosed => 'Byafunzwe';
  @override
  String get disputeTitle => 'Impaka';
  @override
  String get disputeView => 'Reba impaka';
  @override
  String get disputeReason => 'Icyagenze nabi';
  @override
  String get disputeResponse => 'Igisubizo';
  @override
  String get disputeResolution => 'Icyemezo cya Neo';
  @override
  String get disputeNoResponse => 'Turategereje ko undi ruhande asubiza.';
  @override
  String get disputeAwaitingDecision => 'Itsinda ryacu riri gusuzuma impande zombi. Amafaranga abikwa kugeza hafashwe icyemezo.';
  @override
  String get disputeRespondHint => 'Sobanura uruhande rwawe neza kandi utuje — itsinda ryacu risoma impande zombi mbere yo gufata icyemezo.';
  @override
  String get disputeRespondField => 'Igisubizo cyawe';
  @override
  String get disputeRespondSubmit => 'Ohereza igisubizo';
  @override
  String get disputeResponded => 'Igisubizo cyoherejwe';
  @override
  String get disputeStepOpened => 'Impaka zafunguwe';
  @override
  String get disputeStepResponse => 'Igisubizo cyakiriwe';
  @override
  String get disputeStepDecision => 'Icyemezo cya Neo';
  @override
  String get disputeForBooking => 'Ubukode';
  @override
  String get explorePopular => 'Bikunzwe ubu';
  @override
  String get exploreNearby => 'Hafi yawe';
  @override
  String get exploreNearbySub => 'Hafi ya Kigali';
  @override
  String get actPayments => 'Ubwishyu';
  @override
  String get actReports => 'Raporo zanjye';
  @override
  String get actAdmin => 'Ubuyobozi bwa Neo';
  @override
  String get actAdminSub => 'Genzura abakoresha, ibikoresho, amafaranga n’impaka';
  @override
  String get navUnreadHint => 'bitarasomwa';
  @override
  String caseStatus(String wire) =>
      switch (wire) { 'IN_REVIEW' => statusInReview, 'RESOLVED' => statusResolved, 'DISMISSED' => statusDismissed, 'CLOSED' => statusClosed, _ => statusOpen };
  @override
  String reportTarget(String wire) =>
      switch (wire) { 'USER' => targetUser, 'REVIEW' => targetReview, 'MESSAGE' => targetMessage, _ => targetEquipment };

  // -------- Admin console
  @override
  String get adminTitle => 'Ubuyobozi bwa Neo';
  @override
  String get adminOverview => 'Incamake';
  @override
  String get adminUsers => 'Abakoresha';
  @override
  String get adminListings => 'Ibikoresho';
  @override
  String get adminMoney => 'Amafaranga';
  @override
  String get adminTrust => 'Umutekano';
  @override
  String get adminBookings => 'Ubukode';
  @override
  String get adminPending => 'Bitegereje';
  @override
  String get adminCompleted => 'Byarangiye';
  @override
  String get adminRevenue => 'Inyungu ya Neo';
  @override
  String get adminRevenueSub => 'Komisiyo n’amafaranga yo kwamamaza';
  @override
  String get adminOpenReports => 'Raporo zifunguye';
  @override
  String get adminOpenDisputes => 'Impaka zifunguye';
  @override
  String get adminLast30 => 'Iminsi 30 ishize';
  @override
  String get adminNewUsers => 'Abakoresha bashya';
  @override
  String get adminNewBookings => 'Ubukode bushya';
  @override
  String get adminTopListings => 'Ibikoresho bikunzwe';
  @override
  String get adminNeedsAttention => 'Bikeneye kwitabwaho';
  @override
  String get adminAllClear => 'Nta kibazo — nta kintu gitegereje isuzuma.';
  @override
  String get adminVerify => 'Emeza';
  @override
  String get adminVerified => 'Yemejwe';
  @override
  String get adminBan => 'Hagarika';
  @override
  String get adminUnban => 'Kuraho ihagarikwa';
  @override
  String get adminBanned => 'Yahagaritswe';
  @override
  String get adminBanConfirmTitle => 'Guhagarika uyu mukoresha?';
  @override
  String get adminBanConfirmBody => 'Azasohorwa kandi ntazongera gukodesha cyangwa gushyiraho ibikoresho kugeza ihagarikwa rikuweho.';
  @override
  String get adminApprove => 'Emeza';
  @override
  String get adminReject => 'Anga';
  @override
  String get adminApproved => 'Byemejwe';
  @override
  String get adminAwaitingApproval => 'Bitegereje kwemezwa';
  @override
  String get adminTransactions => 'Ibikorwa by’imari';
  @override
  String get adminReviews => 'Ibitekerezo';
  @override
  String get adminDeleteReview => 'Siba igitekerezo';
  @override
  String get adminDeleteReviewBody => 'Ibi bisiba igitekerezo burundu kandi amanota akongera kubarwa.';
  @override
  String get adminReports => 'Raporo';
  @override
  String get adminDisputes => 'Impaka';
  @override
  String get adminResolve => 'Kemura';
  @override
  String get adminDismiss => 'Anga';
  @override
  String get adminCloseCase => 'Funga';
  @override
  String get adminNoteField => 'Icyitonderwa (si ngombwa)';
  @override
  String get adminDecisionField => 'Icyemezo kigezwa ku mpande zombi';
  @override
  String get adminDecisionRequired => 'Banza wandike icyemezo';
  @override
  String get adminSaved => 'Byabitswe';
  @override
  String get adminEmpty => 'Nta kintu kirimo';
  @override
  String get adminEmptyBody => 'Ibintu bishya bizagaragara hano uko abantu bakoresha Neo.';
  @override
  String get adminRenter => 'Ukodesha';
  @override
  String get adminOwner => 'Nyir’igikoresho';
  @override
  String adminReportedBy(String name) =>
      'Byatanzwe na $name';
  @override
  String adminOpenedBy(String name) =>
      'Byafunguwe na $name';
  @override
  String adminBy(String name) =>
      'na $name';

  // -------- Nearby map
  @override
  String get mapTitle => 'Ikarita y’abari hafi';
  @override
  String get mapOpen => 'Ikarita';
  @override
  String get mapLayerAll => 'Bose';
  @override
  String get mapLayerLenders => 'Abakodesha';
  @override
  String get mapLayerBorrowers => 'Abakodesheje';
  @override
  String get mapLender => 'Ukodesha';
  @override
  String get mapBorrower => 'Ukeneye';
  @override
  String get mapSearchArea => 'Shakisha aha hantu';
  @override
  String get mapRecenter => 'Aho ndi';
  @override
  String get mapRadius => 'Intera';
  @override
  String get mapLoading => 'Turashakisha abari hafi yawe…';
  @override
  String get mapEmptyTitle => 'Nta muntu uhari';
  @override
  String get mapEmptyBody => 'Ongera intera cyangwa wimurire ikarita ahandi.';
  @override
  String get mapUsingDefault => 'Turerekana Kigali. Fungura aho uherereye urebe abari hafi yawe.';
  @override
  String get mapLocationOff => 'Serivisi y’aho uherereye irafunze';
  @override
  String get mapLocationDenied => 'Uruhushya rw’aho uherereye rwanzwe';
  @override
  String get mapOpenSettings => 'Igenamiterere';
  @override
  String get mapFromPrice => 'guhera';
  @override
  String get mapViewProfile => 'Umwirondoro';
  @override
  String get mapMessage => 'Andika';
  @override
  String get mapLookingFor => 'Arashaka';
  @override
  String get mapApproxArea => 'Agace kegereye';
  @override
  String get mapMeTitle => 'Nyerekana ku ikarita';
  @override
  String get mapMeSubtitle => 'Reka abakodesha bari hafi bakubone igihe ukeneye ibikoresho';
  @override
  String get mapMeSwitch => 'Abakodesha bari hafi barambona';
  @override
  String get mapMePrivacy => 'Abandi babona agace kegereye gusa (nka km 1), ntibabona aho uri neza. Uvaho nyuma y’iminsi 30 keretse uvuguruye aho uri.';
  @override
  String get mapMeNote => 'Ukeneye iki? (si ngombwa)';
  @override
  String get mapMeNoteHint => 'urugero: intebe 100 n’ihema ku wa Gatandatu';
  @override
  String get mapMeArea => 'Izina ry’agace (si ngombwa)';
  @override
  String get mapMeAreaHint => 'urugero: Kigali - Remera';
  @override
  String get mapMeUseLocation => 'Koresha aho ndi ubu';
  @override
  String get mapMeLocationSet => 'Aho uri habitswe';
  @override
  String get mapMeNoLocation => 'Nta hantu urasangiza';
  @override
  String get mapMeRemove => 'Nkura ku ikarita';
  @override
  String get mapMeSaved => 'Igenamiterere ry’ikarita ryabitswe';
  @override
  String get mapMeRemoved => 'Aho wari uri hasibwe';
  @override
  String get mapMeYou => 'Wowe';
  @override
  String get mapMeVisible => 'Uragaragara';
  @override
  String get mapMeHidden => 'Ntugaragara';
  @override
  String get mapAttribution => 'Amakuru y’ikarita';
  @override
  String mapKmAway(double km) =>
      'kuri km ${km < 1 ? '<1' : km.toStringAsFixed(km < 10 ? 1 : 0)}';
  @override
  String mapListings(int n) =>
      'ibikoresho $n';
  @override
  String mapRadiusKm(int km) =>
      'km $km';
  @override
  String mapActive(String when) =>
      'Yagaragaye $when';
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
