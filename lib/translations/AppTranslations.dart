import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          // Onboarding
          'welcome_to_khabir': 'Welcome to Khabir',
          'choose_your_service': 'Choose Your Service',
          'what_is_your_attribute': 'What Is Your Attribute?',
          'enjoy_perfect_experience':
              'Enjoy the perfect user experience\nwith an expert',
          'choose_or_serve': 'Choose or serve with an expert app',
          'select_your_role':
              'Select your role to get started\nwith the right experience',
          'provider': 'Provider',
          'user': 'User',
          'next': 'Next',
          'back': 'Back',
          'skip': 'Skip',
          'get_started': 'Get Started',
          'warning': 'Warning',
          'please_select_user_type': 'Please select user type',

          // Language Selection
          'english': 'EN',
          'arabic': 'عربي',
          'select_language': 'Select Language',
          'language_changed': 'Language changed successfully',

          // Authentication
          'login': 'Login',
          'register': 'Register',
          'email': 'Email',
          'password': 'Password',
          'confirm_password': 'Confirm Password',
          'phone_number': 'Phone Number',
          'full_name': 'Full Name',
          'forgot_password': 'Forgot Password?',
          'forgot_your_password': 'Forgot your Password?',
          'forgot_password_description':
              'Enter mobile number and we will share a\nlink to create a new password.',
          'enter_mobile_number': 'Enter your mobile number',
          'send': 'Send',
          'dont_have_account': 'Don\'t have an account?',
          'already_have_account': 'Already have an account?',
          'create_account': 'Create Account',
          'create_an_account': 'Create An Account',
          'sign_in': 'Sign In',
          'sign_up': 'Sign Up',
          'welcome_back': 'Welcome Back',
          'login_to_continue': 'Login to continue',
          'enter_email_or_mobile': 'Enter your email',
          'enter_password': 'Enter your password',
          'log_in': 'LOG IN',
          'sign_up_now': 'Sign up now',
          'enter_full_name': 'Enter your full name',
          'enter_email_address': 'Enter your email address',
          'confirm_your_password': 'Confirm your password',
          'choose_your_state': 'Choose your state',
          'choose_your_city': 'Choose your city',
          'choose_your_services': 'Choose your services',
          'enter_description': 'Enter your description',
          'choose_photo_upload': 'Choose photo to upload',
          'photo_selected': 'Photo selected',
          'agree_terms_conditions': 'I agree to the ',
          'terms': 'terms',
          'and': ' and ',
          'conditions': 'conditions',
          'have_account_already': 'Have an account already? ',
          'log_in_link': 'Log in',
          'reset_password': 'Reset password',
          'reset_password_description':
              'Enter a new password and\ndon\'t forget it',
          'enter_new_password': 'Enter new password',
          'confirm_new_password': 'Confirm new password',
          'verify_mobile_number': 'Verify your mobile number',
          'verification_code_sent':
              'We sent you a 6 digit code to verify\nyour mobile number',
          'enter_field_below': 'Enter in the field below.',
          'didnt_get_code': 'Didn\'t get the code? ',
          'resend': 'Resend',
          'expires_in': 'Expires in',
          'confirmation': 'Confirmation',

          // Common UI Elements
          'save': 'Save',
          'cancel': 'Cancel',
          'ok': 'OK',
          'yes': 'Yes',
          'no': 'No',
          'continue': 'Continue',
          'finish': 'Finish',
          'submit': 'Submit',
          'search': 'Search',
          'filter': 'Filter',
          'sort': 'Sort',
          'refresh': 'Refresh',
          'loading': 'Loading...',
          'no_data': 'No data available',
          'error': 'Error',
          'success': 'Success',
          'failed': 'Failed',

          // Navigation
          'home': 'Home',
          'profile': 'Profile',
          'settings': 'Settings',
          'notifications': 'Notifications',
          'help': 'Help',
          'about': 'About',
          'logout': 'Logout',

          // Profile
          'edit': 'Edit',
          'language': 'Language',
          'english_lang': 'English',
          'arabic_lang': 'Arabic',
          'description': 'Description',
          'state': 'State',
          'online': 'Online',
          'offline': 'Offline',
          'terms_and_conditions': 'Terms and Conditions',
          'privacy_policy': 'Privacy Policy',
          'support': 'Support',
          'delete_account': 'Delete Account',
          'log_out': 'Log Out',
          'follow_us': 'Follow Us',

          // Validation Messages
          'field_required': 'This field is required',
          'invalid_email': 'Please enter a valid email',
          'password_too_short': 'Password must be at least 6 characters',
          'passwords_dont_match': 'Passwords don\'t match',
          'invalid_phone': 'Please enter a valid phone number',

          // Dashboard
          'welcome_message': 'Welcome to Khabir',
          'services': 'Services',
          'services_count': 'Num: ',
          'requests': 'Requests',
          'requests_count': 'Num: ',
          'income': 'Income',
          'offers': 'Offers',
          'customer_reviews': 'Customer Reviews',
          'notification_title': 'Notifications',
          'profile_title': 'Profile',
          'whatsapp_title': 'WhatsApp',

          // Requests
          'no_requests': 'No requests currently',
          'location': 'Location',
          'complete': 'Complete',
          'completed_status': 'Completed',
          'cancelled_status': 'Cancelled',
          'pending_status': 'Pending',
          'incomplete_status': 'Cancelled',
          'total_price': 'Total Price',

          // Services Management
          'add_service': 'Add Service',
          'service_category': 'Service Category',
          'all_services': 'All Services',
          'choose_category': 'Choose Category',
          'commission': 'Commission',
          'price_label': 'PRICE',
          'no_services_available': 'No services available',
          'all_services_added': 'All services already added',
          'add': 'Add',
          'deleting': 'Deleting...',
          'service_disabled': 'Service Disabled',
          'undefined_service': 'Undefined Service',
          'commission_info': 'Commission: ',
          'disable': 'Disable',
          'enable': 'Enable',
          'delete': 'Delete',
          'no_services': 'No Services',
          'add_first_service': 'Add your first service',
          'add_service_button': 'Add Service',
          'request_unlisted_service': 'Request unlisted service',

          // Invoices
          'loading_invoices': 'Loading invoices...',
          'no_invoices': 'No invoices available',
          'completed_requests': 'Completed requests',
          'gross_income': 'Gross income',
          'after_commission': 'After commission',
          'customer_name': 'Customer Name',
          'phone': 'Phone',
          'id': 'ID',
          'category': 'Category',
          'type': 'Type',
          'number': 'Number',
          'duration': 'Duration',
          'payment_status': 'Payment Status',
          'paid': 'Paid',
          'not_paid': 'Not paid',
          'omr': 'OMR',

          // Offers Management
          'offers_management': 'Offers Management',
          'services_active_offers': 'Services & Active Offers',
          'active_offer_discount': 'Active Offer - @0% Discount',
          'price': 'Price',
          'add_offer': 'Add Offer',
          'delete_offer': 'Delete Offer',
          'available_offers': 'Available Offers (@0)',
          'add_services_first': 'Add Services First',
          'active': 'Active',
          'inactive': 'Inactive',
          'discount': 'Discount',
          'original_price': 'Original Price',
          'offer_price': 'Offer Price',
          'percentage': 'Percentage',
          'title': 'Title',
          'welcome': 'Welcome',
          'khabir': 'Khabir',
          'create': 'Create',
          'update': 'Update',
          'confirm': 'Confirm',
          'info': 'Information',
          'enabled': 'Enabled',
          'disabled': 'Disabled',
          'status': 'Status',

          'edit_offer': 'Edit Offer',
          'new_price': 'New Price',
          'current_offer': 'Current Offer',
          'offer_updated_successfully': 'Offer updated successfully',
          'offer_price_must_be_less':
              'Offer price must be less than original price',
          'title_required': 'Title is required',
          'description_required': 'Description is required',
          'price_required': 'Price is required',
          'enter_valid_price': 'Enter valid price',
          'select_end_date': 'Select end date',
          'end_date_must_be_future': 'End date must be in the future',

          // Additional Keys from Controllers
          'accepted_status': 'Accepted',
          'unknown_status': 'Unknown',
          'service': 'Service',
          'not_specified': 'Not Specified',
          'now': 'Now',
          'services_info': 'Services Information',
          'single_service_only': 'This order contains only one service',
          'services_details': 'Services Details',
          'order_number': 'Order Number',
          'customer': 'Customer',
          'quantity': 'Quantity',
          'order_summary': 'Order Summary',
          'total_services': 'Total Services',
          'total_quantity': 'Total Quantity',
          'piece': 'Piece',
          'close': 'Close',
          'accept_order': 'Accept Order',
          'accept_order_question': 'Do you want to accept order',
          'complate_order_question': 'Do you want to complate order',
          'in': 'in',
          'confirm_acceptance': 'Confirm Acceptance',
          'view_details': 'View Details',
          'accept': 'Accept',
          'accepted': 'Accepted!',
          'order_accepted_successfully': 'Order accepted successfully',
          'complate_accepted_successfully': 'Order complated successfully',

          'reject_order_question': 'Do you want to reject order',
          'cannot_undo': 'You cannot undo this decision',
          'confirm_rejection': 'Confirm Rejection',
          'reject': 'Reject',
          'rejected': 'Rejected',
          'order_rejected': 'Order rejected',
          'view_customer_location': 'View customer location',
          'call_customer': 'Call Customer',
          'call_customer_question': 'Do you want to call the customer?',
          'call': 'Call',
          'opening_phone_app': 'Opening phone app to call customer',
          'updated': 'Updated',
          'notifications_updated': 'Notifications list updated',
          'clear_all_notifications': 'Clear All Notifications',
          'clear_all_confirm':
              'Are you sure you want to clear all notifications?',
          'reject_all_pending': 'This will reject all pending orders',
          'clear': 'Clear',
          'cleared': 'Cleared',
          'all_notifications_cleared':
              'All notifications cleared and pending orders rejected',
          'others': 'Others',
          'notification_load_error': 'Failed to load notifications',
          'accept_order_error': 'Failed to accept order',
          'reject_order_error': 'Failed to reject order',
          'clear_notifications_error': 'Failed to clear notifications',
          'select_at_least_one_service': 'Please select at least one service',
          'enter_price_for_service': 'Please enter a price for the service',
          'enter_valid_price_for_service':
              'Please enter a valid price for the service',
          'services_added_successfully': 'Added services successfully',
          'error_adding_services': 'Error adding services',
          'payment_request_sent': 'Payment request sent successfully',
          'error_contacting_admin': 'Error contacting admin',
          'whatsapp_opened': 'WhatsApp opened',
          'contact_admin': 'You can now contact the admin',
          'cannot_open_whatsapp':
              'Cannot open WhatsApp. Ensure the app is installed on your device',
          'support_message':
              "Hello, I want to send your commission for order number",
          'amount': 'with amount',
          'filter_by_date': 'Filter by Date',
          'filter_records': 'Records filtered from',
          'to': 'to',
          'income_data_updated': 'Income data updated',
          'filters_cleared': 'All filters cleared',

          // Additional Keys for Months (from OffersController)
          'january': 'January',
          'february': 'February',
          'march': 'March',
          'april': 'April',
          'may': 'May',
          'june': 'June',
          'july': 'July',
          'august': 'August',
          'september': 'September',
          'october': 'October',
          'november': 'November',
          'december': 'December',

          // Additional Keys for Sample Data (from IncomeController)
          'category_electric': 'Electricity',
          'type_change_bulbs': 'Change Bulbs',

          "order_details": "Order Details",
          "service_summary": "Service Summary",
          "services_count_text": "services",
          "total_amount": "Total Amount",
          "service_description": "Description",
          "service_quantity": "Quantity",
          "service_price": "Price",
          "currency_omr": "OMR",
          "dialog_close": "Close",
          "dialog_accept_order": "Accept Order",

          "start_tracking": "update tracking",
          "tracking_active": "tracking active",

          // Multiple services
          'multiple_services': 'Multiple Services',
          'qty': 'Qty',
          'total': 'Total',

          // Tracking
          'tracking_started': 'Tracking Started',
          'tracking_started_message': 'Location tracking started for order',
          'tracking_stopped': 'Tracking Stopped',
          'tracking_stopped_message': 'Location tracking stopped for order',
          'tracking_error': 'Tracking Error',

          // Location permissions
          'location_error': 'Location Error',
          'location_service_required':
              'Location service must be enabled to start tracking',
          'unable_to_get_location': 'Unable to get your current location',
          'location_permission_error':
              'Error occurred while checking location permissions',
          'location_setup_failed':
              'Failed to setup location. Please try again.',

          // Location dialogs
          'location_permission_required': 'Location Permission Required',
          'location_permission_message':
              'App needs access to your location to track orders',
          'location_permission_denied': 'Location Permission Denied',
          'location_permission_denied_message':
              'Location permission was permanently denied. Please go to app settings and enable location permission.',
          'open_settings': 'Open Settings',
          'location_service_disabled': 'Location Service Disabled',
          'location_service_message':
              'Location service (GPS) must be enabled in device settings to start tracking.',

          'service_type': 'Service Type',
          'service_duration': 'Service Duration',

          'phone_copied': 'Copied',
          'phone_copied_message': 'Phone number copied to clipboard',
          'copy_error': 'Copy Error',
          'copy_error_message': 'Failed to copy phone number',

          'reviews': 'Reviews',
          'average_rating': 'Average Rating',
          'whatsapp_help_message': 'Hello, I need help with Khabir app',
          'whatsapp_error_message':
              'An error occurred while trying to open WhatsApp',
          'hello': 'Hello',
          'welcome_to_khabir_app': 'Welcome to Khabir app',
          'data_updated_successfully': 'Data updated successfully',

          // General states
          'done': 'Done',
          'sent': 'Sent',

          // Login and logout
          'login_success': 'Login successful',
          'logout_success': 'Logout successful',
          'logout_local_success':
              'Logged out locally (failed to connect to server)',
          'logout_error': 'An error occurred while logging out',
          'logout_failed': 'Logout failed',

          // Registration
          'please_correct_data': 'Please correct the entered data',
          'verification_code_resent': 'Verification code resent',
          'registration_failed': 'Failed to send data',
          'account_creation_error':
              'An unexpected error occurred while creating the account',

          // Password
          'password_reset_success': 'Password reset successful',
          'password_reset_failed': 'Failed to reset password',
          'code_sending_failed': 'Failed to send code',
          'server_unknown_error': 'Unknown server error',

          // Data validation - Name
          'please_enter_full_name': 'Please enter full name',
          'name_min_length': 'Name must be at least 2 characters',

          // Data validation - Password
          'password_min_length': 'Password must be at least 6 characters',
          'password_mismatch': 'Passwords do not match',
          'please_enter_password': 'Please enter password',
          'please_enter_new_password': 'Please enter new password',

          // Data validation - Governorate and state
          'please_select_governorate': 'Please select governorate',
          'please_select_state': 'Please select state',
          'please_select_area': 'Please select area',

          // Data validation - Categories and services
          'please_select_category': 'Please select at least one category',
          'please_select_service': 'Please select at least one service',

          // Terms and conditions
          'please_accept_terms': 'Please accept terms and conditions',

          // Phone and email
          'please_enter_email_phone': 'Please enter email or phone number',
          'please_enter_valid_email_phone':
              'Please enter a valid email or phone number',
          'please_enter_phone': 'Please enter phone number',
          'please_enter_valid_phone': 'Please enter a valid phone number',
          'phone_min_length': 'Phone number must be at least 10 digits',

          // Verification code
          'please_enter_verification_code': 'Please enter verification code',
          'verification_code_numbers_only':
              'Verification code must contain numbers only',
          'verification_code_six_digits': 'Verification code must be 6 digits',

          // Images
          'image_selected': 'Image selected',
          'image_selected_success': 'Image selected successfully',
          'image_selection_error': 'An error occurred while selecting image',

          // Main page titles
          'notifications_title': 'Notifications',
          'app_name': 'Khabeer',

          // Counters and labels
          'notifications_count': 'Notifications count:',
          'pending_requests': 'pending request',
          'services_label': 'service',
          'view_all': 'View all',
          'more_services': 'more service',

          // Status messages
          'waiting_for_acceptance': 'Waiting for acceptance',
          'customer_default_name': 'Customer',

          // Date and time
          'order_date': 'Order date',
          'required_duration': 'Required duration',
          'today': 'Today',
          'yesterday': 'Yesterday',
          'since': 'since',
          'minutes': 'minutes',
          'hours': 'hours',
          'days': 'days',
          'am': 'AM',
          'pm': 'PM',
          'immediate': 'Immediate',
          'hour': 'hour',
          'minute': 'minute',
          'day': 'day',

          // Location and details
          'state_label': 'State',
          'view_location': 'View location',
          'currency': 'OMR',

          // Action buttons
          'accept_request': 'Accept',
          'reject_request': 'Reject',
          'details_button': 'Details',

          // Loading and empty states
          'loading_notifications': 'Loading notifications...',
          'no_pending_requests': 'No pending requests',
          'new_requests_will_appear_here': 'New requests will appear here',

          "connection_timeout": "Connection timeout, please try again",
          "invalid_data": "Invalid data",
          "invalid_credentials": "Invalid login credentials",
          "access_forbidden": "Access forbidden",
          "account_not_found": "Account not found",
          "phone_already_used": "Phone number already in use",
          "invalid_data_format": "Invalid data format",
          "server_error": "Server error, please try again later",
          "unexpected_error": "An unexpected error occurred",
          "operation_cancelled": "Operation cancelled",
          "no_internet_connection": "No internet connection",
          "connection_error": "Connection error occurred",
          'agree_to': 'I agree to',

          'enter_otp_and_new_password':
              'Enter the verification code and your new password',
          'verification_code': 'Verification Code',
          'new_password': 'New Password',
          'clear_form': 'Clear Form',
          'sent_to': 'Sent to',

          // Common Messages
          'otp_entered_completely': 'Verification code entered completely',
          'form_cleared': 'Form Cleared',
          'form_has_been_cleared': 'The form has been cleared successfully',

          // Validation Messages
          'phone_number_missing': 'Phone number is missing',
          'phone_number_missing_please_go_back':
              'Phone number is missing, please go back and enter it again',

          // Phone validation messages (add these based on your PhoneHelper)
          'invalid_phone_number': 'Invalid phone number',
          'phone_number_too_short': 'Phone number is too short',
          'phone_number_too_long': 'Phone number is too long',
          'invalid_phone_format': 'Invalid phone number format',

          "phone_already_registered": "Phone number is already registered",

          // Validation messages - Phone
          'phone_required': 'Phone number is required',
          'phone_numbers_only': 'Only numbers are allowed',
          'phone_invalid_length': 'Phone number must be 8 digits',
          'phone_max_length': 'Phone number must not exceed 8 digits',

          // Validation messages - Password
          'password_required': 'Password is required',

          // Error messages
          'network_error': 'Network connection error',
          'account_disabled': 'Account has been disabled',
          'empty_response': 'Empty response from server',
          'invalid_token': 'Invalid access token',
          'invalid_user_data': 'Invalid user data',

          'invalid_otp': 'invalid otp',

          'after': 'After',
          'tomorrow': 'Tomorrow',
          'scheduled_time': 'Scheduled Time',
        },
        'ar_SA': {
          // Onboarding
          'welcome_to_khabir': 'مرحباً بك في خبير',
          'choose_your_service': 'اختر خدمتك',
          'what_is_your_attribute': 'ما هي صفتك؟',
          'enjoy_perfect_experience':
              'استمتع بتجربة المستخدم المثالية\nمع خبير',
          'choose_or_serve': 'اختر أو قدم الخدمة مع تطبيق خبير',
          'select_your_role': 'اختر دورك للبدء\nبالتجربة المناسبة',
          'provider': 'مقدم خدمة',
          'user': 'مستخدم',
          'next': 'التالي',
          'back': 'رجوع',
          'skip': 'تخطي',
          'get_started': 'ابدأ الآن',
          'warning': 'تنبيه',
          'please_select_user_type': 'يرجى اختيار نوع المستخدم',

          // Language Selection
          'english': 'EN',
          'arabic': 'عربي',
          'select_language': 'اختر اللغة',
          'language_changed': 'تم تغيير اللغة بنجاح',

          // Authentication
          'login': 'تسجيل الدخول',
          'register': 'إنشاء حساب',
          'email': 'البريد الإلكتروني',
          'password': 'كلمة المرور',
          'confirm_password': 'تأكيد كلمة المرور',
          'phone_number': 'رقم الهاتف',
          'full_name': 'الاسم الكامل',
          'forgot_password': 'نسيت كلمة المرور؟',
          'forgot_your_password': 'نسيت كلمة المرور؟',
          'forgot_password_description':
              'أدخل رقم الهاتف المحمول وسنرسل لك\nرابط لإنشاء كلمة مرور جديدة.',
          'enter_mobile_number': 'أدخل رقم الهاتف المحمول',
          'send': 'إرسال',
          'dont_have_account': 'ليس لديك حساب؟',
          'already_have_account': 'لديك حساب بالفعل؟',
          'create_account': 'إنشاء حساب',
          'create_an_account': 'إنشاء حساب',
          'sign_in': 'دخول',
          'sign_up': 'تسجيل',
          'welcome_back': 'مرحباً بعودتك',
          'login_to_continue': 'سجل دخولك للمتابعة',
          'enter_email_or_mobile': 'أدخل بريدك الإلكتروني',
          'enter_password': 'أدخل كلمة المرور',
          'log_in': 'تسجيل الدخول',
          'sign_up_now': 'إنشاء حساب الآن',
          'enter_full_name': 'أدخل اسمك الكامل',
          'enter_email_address': 'أدخل عنوان بريدك الإلكتروني',
          'confirm_your_password': 'أكد كلمة المرور',
          'choose_your_state': 'اختر المحافظة',
          'choose_your_city': 'اختر المدينة',
          'choose_your_services': 'اختر خدماتك',
          'enter_description': 'أدخل وصفك',
          'choose_photo_upload': 'اختر صورة للرفع',
          'photo_selected': 'تم اختيار الصورة',
          'agree_terms_conditions': 'أوافق على ',
          'terms': 'الشروط',
          'and': ' و ',
          'conditions': 'الأحكام',
          'have_account_already': 'لديك حساب بالفعل؟ ',
          'log_in_link': 'سجل دخولك',
          'reset_password': 'إعادة تعيين كلمة المرور',
          'reset_password_description': 'أدخل كلمة مرور جديدة\nولا تنسها',
          'enter_new_password': 'أدخل كلمة المرور الجديدة',
          'confirm_new_password': 'أكد كلمة المرور الجديدة',
          'verify_mobile_number': 'تحقق من رقم هاتفك المحمول',
          'verification_code_sent':
              'أرسلنا لك رمز مكون من 6 أرقام للتحقق\nمن رقم هاتفك المحمول',
          'enter_field_below': 'أدخله في الحقل أدناه.',
          'didnt_get_code': 'لم تحصل على الرمز؟ ',
          'resend': 'إعادة إرسال',
          'expires_in': 'ينتهي في',
          'confirmation': 'تأكيد',

          // Common UI Elements
          'save': 'حفظ',
          'cancel': 'إلغاء',
          'ok': 'موافق',
          'yes': 'نعم',
          'no': 'لا',
          'continue': 'متابعة',
          'finish': 'إنهاء',
          'submit': 'إرسال',
          'search': 'بحث',
          'filter': 'تصفية',
          'sort': 'ترتيب',
          'refresh': 'تحديث',
          'loading': 'جاري التحميل...',
          'no_data': 'لا توجد بيانات متاحة',
          'error': 'خطأ',
          'success': 'نجح',
          'failed': 'فشل',

          // Navigation
          'home': 'الرئيسية',
          'profile': 'الملف الشخصي',
          'settings': 'الإعدادات',
          'notifications': 'الإشعارات',
          'help': 'المساعدة',
          'about': 'حول التطبيق',
          'logout': 'تسجيل الخروج',

          // Profile
          'edit': 'تعديل',
          'language': 'اللغة',
          'english_lang': 'English',
          'arabic_lang': 'العربية',
          'description': 'الوصف',
          'state': 'الحالة',
          'online': 'متصل',
          'offline': 'غير متصل',
          'terms_and_conditions': 'الشروط والأحكام',
          'privacy_policy': 'سياسة الخصوصية',
          'support': 'الدعم الفني',
          'delete_account': 'حذف الحساب',
          'log_out': 'تسجيل الخروج',
          'follow_us': 'تابعنا على',

          // Validation Messages
          'field_required': 'هذا الحقل مطلوب',
          'invalid_email': 'يرجى إدخال بريد إلكتروني صحيح',
          'password_too_short': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
          'passwords_dont_match': 'كلمات المرور غير متطابقة',
          'invalid_phone': 'يرجى إدخال رقم هاتف صحيح',

          // Dashboard
          'welcome_message': 'مرحباً بك في خبير',
          'services': 'الخدمات',
          'services_count': 'العدد: ',
          'requests': 'الطلبات',
          'requests_count': 'العدد: ',
          'income': 'الدخل',
          'offers': 'العروض',
          'customer_reviews': 'تقييمات العملاء',
          'notification_title': 'الإشعارات',
          'profile_title': 'الملف الشخصي',
          'whatsapp_title': 'واتساب',

          // Requests
          'no_requests': 'لا توجد طلبات حالياً',
          'location': 'الموقع',
          'complete': 'إكمال',
          'completed_status': 'تم الإكمال',
          'cancelled_status': 'تم الإلغاء',
          'pending_status': 'معلق',
          'incomplete_status': 'ملغي',
          'total_price': 'السعر الإجمالي',

          // Services Management
          'add_service': 'إضافة خدمة',
          'service_category': 'فئة الخدمة',
          'all_services': 'جميع الخدمات',
          'choose_category': 'اختر الفئة',
          'commission': 'العمولة',
          'price_label': 'السعر',
          'no_services_available': 'لا توجد خدمات متاحة',
          'all_services_added': 'جميع الخدمات مضافة بالفعل',
          'add': 'إضافة',
          'deleting': 'جاري الحذف...',
          'service_disabled': 'الخدمة معطلة',
          'undefined_service': 'خدمة غير محددة',
          'commission_info': 'العمولة: ',
          'disable': 'تعطيل',
          'enable': 'تفعيل',
          'delete': 'حذف',
          'no_services': 'لا توجد خدمات',
          'add_first_service': 'قم بإضافة خدماتك الأولى',
          'add_service_button': 'إضافة خدمة',
          'request_unlisted_service': 'طلب خدمة غير موجودة',

          // Invoices
          'loading_invoices': 'جاري تحميل الفواتير...',
          'no_invoices': 'لا توجد فواتير حالياً',
          'completed_requests': 'الطلبات المكتملة',
          'gross_income': 'إجمالي الدخل',
          'after_commission': 'بعد العمولة',
          'customer_name': 'اسم العميل',
          'phone': 'الهاتف',
          'id': 'المعرف',
          'category': 'الفئة',
          'type': 'النوع',
          'number': 'الرقم',
          'duration': 'المدة',
          'payment_status': 'حالة الدفع',
          'paid': 'مدفوع',
          'not_paid': 'غير مدفوع',
          'omr': 'ر.ع',

          // Offers Management
          'offers_management': 'إدارة العروض',
          'services_active_offers': 'الخدمات والعروض النشطة',
          'active_offer_discount': 'عرض نشط - خصم @0%',
          'price': 'السعر',
          'add_offer': 'إضافة عرض',
          'delete_offer': 'حذف العرض',
          'available_offers': 'العروض المتاحة (@0)',
          'add_services_first': 'قم بإضافة الخدمات أولاً',
          'active': 'نشط',
          'inactive': 'غير نشط',
          'discount': 'خصم',
          'original_price': 'السعر الأصلي',
          'offer_price': 'سعر العرض',
          'percentage': 'النسبة المئوية',
          'title': 'العنوان',
          'welcome': 'مرحباً بك',
          'khabir': 'خبير',
          'create': 'إنشاء',
          'update': 'تحديث',
          'confirm': 'تأكيد',
          'info': 'معلومات',
          'enabled': 'مفعل',
          'disabled': 'معطل',
          'status': 'الحالة',

          'edit_offer': 'تعديل العرض',
          'new_price': 'السعر الجديد',
          'current_offer': 'العرض الحالي',
          'offer_updated_successfully': 'تم تحديث العرض بنجاح',
          'offer_price_must_be_less':
              'سعر العرض يجب أن يكون أقل من السعر الأصلي',
          'title_required': 'العنوان مطلوب',
          'description_required': 'الوصف مطلوب',
          'price_required': 'السعر مطلوب',
          'enter_valid_price': 'أدخل سعر صحيح',
          'select_end_date': 'اختر تاريخ الانتهاء',
          'end_date_must_be_future': 'تاريخ الانتهاء يجب أن يكون في المستقبل',

          // Additional Keys from Controllers
          'accepted_status': 'مقبول',
          'unknown_status': 'غير معروف',
          'service': 'خدمة',
          'not_specified': 'غير محدد',
          'now': 'الآن',
          'services_info': 'معلومات الخدمات',
          'single_service_only': 'هذا الطلب يحتوي على خدمة واحدة فقط',
          'services_details': 'تفاصيل الخدمات',
          'order_number': 'رقم الطلب',
          'customer': 'العميل',
          'quantity': 'الكمية',
          'order_summary': 'ملخص الطلب',
          'total_services': 'إجمالي الخدمات',
          'total_quantity': 'إجمالي الكمية',
          'piece': 'قطعة',
          'close': 'إغلاق',
          'accept_order': 'قبول الطلب',
          'accept_order_question': 'هل تريد قبول الطلب',
          'complate_order_question': 'هل تريد إكمال الطلب',

          'in': 'في',
          'confirm_acceptance': 'تأكيد القبول',
          'view_details': 'عرض التفاصيل',
          'accept': 'قبول',
          'accepted': 'تم القبول!',
          'order_accepted_successfully': 'تم قبول الطلب بنجاح',
          'complate_accepted_successfully': 'تم إكمال الطلب بنجاح',

          'reject_order_question': 'هل تريد رفض طلب',
          'cannot_undo': 'لن تتمكن من التراجع عن هذا القرار',
          'confirm_rejection': 'تأكيد الرفض',
          'reject': 'رفض',
          'rejected': 'تم الرفض',
          'order_rejected': 'تم رفض الطلب',
          'view_customer_location': 'عرض موقع العميل',
          'call_customer': 'الاتصال بالعميل',
          'call_customer_question': 'هل تريد الاتصال بالعميل؟',
          'call': 'اتصال',
          'opening_phone_app': 'سيتم فتح تطبيق الهاتف للاتصال بالعميل',
          'updated': 'تم التحديث',
          'notifications_updated': 'تم تحديث قائمة الإشعارات',
          'clear_all_notifications': 'مسح جميع الإشعارات',
          'clear_all_confirm': 'هل أنت متأكد من مسح جميع الإشعارات؟',
          'reject_all_pending': 'هذا سيرفض جميع الطلبات المعلقة',
          'clear': 'مسح',
          'cleared': 'تم المسح',
          'all_notifications_cleared':
              'تم مسح جميع الإشعارات ورفض الطلبات المعلقة',
          'others': 'أخرى',
          'notification_load_error': 'فشل في تحميل الإشعارات',
          'accept_order_error': 'فشل في قبول الطلب',
          'reject_order_error': 'فشل في رفض الطلب',
          'clear_notifications_error': 'فشل في مسح الإشعارات',
          'select_at_least_one_service': 'يرجى اختيار خدمة واحدة على الأقل',
          'enter_price_for_service': 'يرجى إدخال سعر للخدمة',
          'enter_valid_price_for_service': 'يرجى إدخال سعر صحيح للخدمة',
          'services_added_successfully': 'تم إضافة الخدمات بنجاح',
          'error_adding_services': 'خطأ أثناء إضافة الخدمات',
          'payment_request_sent': 'تم إرسال طلب الدفع بنجاح',
          'error_contacting_admin': 'خطأ أثناء التواصل مع الإدارة',
          'whatsapp_opened': 'تم فتح واتساب',
          'contact_admin': 'يمكنك الآن التواصل مع الإدارة',
          'cannot_open_whatsapp':
              'لا يمكن فتح واتساب. تأكد من وجود التطبيق على جهازك',
          'support_message': 'مرحباً، أريد إرسال عمولتكم للطلب رقم',
          'amount': 'بقيمة',
          'filter_by_date': 'تصفية حسب التاريخ',
          'filter_records': 'تم تصفية السجلات من',
          'to': 'إلى',
          'income_data_updated': 'تم تحديث بيانات الدخل',
          'filters_cleared': 'تم مسح جميع المرشحات',

          // Additional Keys for Months (from OffersController)
          'january': 'يناير',
          'february': 'فبراير',
          'march': 'مارس',
          'april': 'أبريل',
          'may': 'مايو',
          'june': 'يونيو',
          'july': 'يوليو',
          'august': 'أغسطس',
          'september': 'سبتمبر',
          'october': 'أكتوبر',
          'november': 'نوفمبر',
          'december': 'ديسمبر',

          // Additional Keys for Sample Data (from IncomeController)
          'category_electric': 'كهربا',
          'type_change_bulbs': 'غيير لمبات',

          "order_details": "تفاصيل الطلب",
          "service_summary": "ملخص الطلب",
          "services_count_text": "خدمة",
          "total_amount": "المبلغ الإجمالي",
          "service_description": "الوصف",
          "service_quantity": "الكمية",
          "service_price": "السعر",
          "currency_omr": "ريال",
          "dialog_close": "إغلاق",
          "dialog_accept_order": "قبول الطلب",

          "start_tracking": "تحديث التتبع",
          "tracking_active": "التتبع نشط",

          // الخدمات المتعددة
          'multiple_services': 'خدمات متعددة',
          'qty': 'الكمية',
          'total': 'المجموع',

          // التتبع
          'tracking_started': 'تحديث التتبع',
          'tracking_started_message': 'تم تحديث تتبع موقعك للطلبية',
          'tracking_stopped': 'إيقاف التتبع',
          'tracking_stopped_message': 'تم إيقاف تتبع الموقع للطلبية',
          'tracking_error': 'خطأ في التتبع',

          // صلاحيات الموقع
          'location_error': 'خطأ في الموقع',
          'location_service_required': 'يجب تفعيل خدمة الموقع لبدء التتبع',
          'unable_to_get_location': 'لا يمكن الحصول على موقعك الحالي',
          'location_permission_error': 'حدث خطأ أثناء التحقق من صلاحيات الموقع',
          'location_setup_failed':
              'فشل في إعداد الموقع. يرجى المحاولة مرة أخرى.',

          // حوارات الموقع
          'location_permission_required': 'إذن الموقع مطلوب',
          'location_permission_message':
              'يجب السماح للتطبيق بالوصول إلى موقعك لبدء تتبع الطلبية',
          'location_permission_denied': 'إذن الموقع مرفوض',
          'location_permission_denied_message':
              'تم رفض إذن الموقع نهائياً. يرجى الذهاب إلى إعدادات التطبيق وتفعيل صلاحية الموقع.',
          'open_settings': 'فتح الإعدادات',
          'location_service_disabled': 'خدمة الموقع معطلة',
          'location_service_message':
              'يجب تفعيل خدمة الموقع (GPS) في إعدادات الجهاز لبدء تتبع الطلبية.',

          'service_type': 'نوع الخدمة',
          'service_duration': 'مدة الخدمة',

          'phone_copied': 'تم النسخ',
          'phone_copied_message': 'تم نسخ رقم الهاتف إلى الحافظة',
          'copy_error': 'خطأ في النسخ',
          'copy_error_message': 'فشل في نسخ رقم الهاتف',

          'reviews': 'التقييمات',
          'average_rating': 'متوسط التقييم',
          'whatsapp_help_message': 'مرحباً، أحتاج المساعدة في تطبيق خبير',
          'whatsapp_error_message': 'حدث خطأ أثناء محاولة فتح واتساب',
          'hello': 'مرحباً',
          'welcome_to_khabir_app': 'مرحباً بك في تطبيق خبير',
          'data_updated_successfully': 'تم تحديث البيانات بنجاح',

          // حالات عامة
          'done': 'تم',
          'sent': 'تم الإرسال',

          // تسجيل الدخول والخروج
          'login_success': 'تم تسجيل الدخول بنجاح',
          'logout_success': 'تم تسجيل الخروج بنجاح',
          'logout_local_success':
              'تم تسجيل الخروج محلياً (فشل في الاتصال بالخادم)',
          'logout_error': 'حدث خطأ أثناء تسجيل الخروج',
          'logout_failed': 'فشل تسجيل الخروج',

          // التسجيل
          'please_correct_data': 'يرجى تصحيح البيانات المدخلة',
          'verification_code_resent': 'تم إعادة إرسال رمز التحقق',
          'registration_failed': 'فشل في إرسال البيانات',
          'account_creation_error': 'حصل خطأ غير متوقع أثناء إنشاء الحساب',

          // كلمة المرور
          'password_reset_success': 'تم تغيير كلمة المرور بنجاح',
          'password_reset_failed': 'فشل في تغيير كلمة المرور',
          'code_sending_failed': 'فشل في إرسال الرمز',
          'server_unknown_error': 'خطأ غير معروف في الخادم',

          // التحقق من البيانات - الاسم
          'please_enter_full_name': 'يرجى إدخال الاسم الكامل',
          'name_min_length': 'الاسم يجب أن يكون حرفين على الأقل',

          // التحقق من البيانات - كلمة المرور
          'password_min_length': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
          'password_mismatch': 'كلمة المرور غير متطابقة',
          'please_enter_password': 'يرجى إدخال كلمة المرور',
          'please_enter_new_password': 'يرجى إدخال كلمة المرور الجديدة',

          // التحقق من البيانات - المحافظة والولاية
          'please_select_governorate': 'يرجى اختيار المحافظة',
          'please_select_state': 'يرجى اختيار الولاية',
          'please_select_area': 'يرجى اختيار المنطقة',

          // التحقق من البيانات - الفئات والخدمات
          'please_select_category': 'يرجى اختيار فئة واحدة على الأقل',
          'please_select_service': 'يرجى اختيار خدمة واحدة على الأقل',

          // الشروط والأحكام
          'please_accept_terms': 'يرجى الموافقة على الشروط والأحكام',

          // رقم الهاتف والبريد الإلكتروني
          'please_enter_email_phone': 'يرجى إدخال رقم الهاتف',
          'please_enter_valid_email_phone': 'يرجى إدخال رقم هاتف صحيح',
          'please_enter_phone': 'يرجى إدخال رقم الهاتف',
          'please_enter_valid_phone': 'يرجى إدخال رقم هاتف صحيح',
          'phone_min_length': 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل',

          // رمز التحقق
          'please_enter_verification_code': 'يرجى إدخال رمز التحقق',
          'verification_code_numbers_only':
              'رمز التحقق يجب أن يحتوي على أرقام فقط',
          'verification_code_six_digits': 'رمز التحقق يجب أن يكون 6 أرقام',

          // الصور
          'image_selected': 'تم اختيار الصورة',
          'image_selected_success': 'تم اختيار الصورة بنجاح',
          'image_selection_error': 'حدث خطأ أثناء اختيار الصورة',

          // Main page titles
          'notifications_title': 'الإشعارات',
          'app_name': 'خبير',

          // Counters and labels
          'notifications_count': 'عدد الإشعارات:',
          'pending_requests': 'طلب معلق',
          'services_label': 'خدمة',
          'view_all': 'عرض الكل',
          'more_services': 'خدمة أخرى',

          // Status messages
          'waiting_for_acceptance': 'في انتظار القبول',
          'customer_default_name': 'عميل',

          // Date and time
          'order_date': 'تاريخ الطلب',
          'required_duration': 'المدة المطلوبة',
          'today': 'اليوم',
          'yesterday': 'أمس',
          'since': 'منذ',
          'minutes': 'دقيقة',
          'hours': 'ساعة',
          'days': 'أيام',
          'am': 'ص',
          'pm': 'م',
          'immediate': 'فوري',
          'hour': 'ساعة',
          'minute': 'دقيقة',
          'day': 'يوم',

          // Location and details
          'state_label': 'الولاية',
          'view_location': 'عرض الموقع',
          'currency': 'OMR',

          // Action buttons
          'accept_request': 'قبول الطلب',
          'reject_request': 'رفض الطلب',
          'details_button': 'التفاصيل',

          // Loading and empty states
          'loading_notifications': 'جاري تحميل الإشعارات...',
          'no_pending_requests': 'لا توجد طلبات معلقة',
          'new_requests_will_appear_here': 'ستظهر الطلبات الجديدة هنا',

          "connection_timeout": "انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى",
          "invalid_data": "بيانات غير صحيحة",
          "invalid_credentials": "بيانات الدخول غير صحيحة",
          "access_forbidden": "غير مسموح بالوصول",
          "account_not_found": "الحساب غير موجود",
          "phone_already_used": "رقم الهاتف مستخدم مسبقاً",
          "invalid_data_format": "بيانات غير صالحة",
          "server_error": "خطأ في الخادم، يرجى المحاولة لاحقاً",
          "unexpected_error": "حدث خطأ غير متوقع",
          "operation_cancelled": "تم إلغاء العملية",
          "no_internet_connection": "لا يوجد اتصال بالإنترنت",
          "connection_error": "حدث خطأ في الاتصال",

          'agree_to': 'أوافق على',

          'enter_otp_and_new_password': 'أدخل رمز التحقق وكلمة المرور الجديدة',
          'invalid_otp': 'رمز التحقق غير صحيح',

          'verification_code': 'رمز التحقق',
          'new_password': 'كلمة المرور الجديدة',
          'clear_form': 'مسح النموذج',
          'sent_to': 'مُرسل إلى',

          // Common Messages
          'otp_entered_completely': 'تم إدخال رمز التحقق بالكامل',
          'form_cleared': 'تم مسح النموذج',
          'form_has_been_cleared': 'تم مسح النموذج بنجاح',

          // Validation Messages
          'phone_number_missing': 'رقم الهاتف مفقود',
          'phone_number_missing_please_go_back':
              'رقم الهاتف مفقود، يرجى العودة وإدخاله مرة أخرى',

          // Phone validation messages (add these based on your PhoneHelper)
          'invalid_phone_number': 'رقم الهاتف غير صحيح',
          'phone_number_too_short': 'رقم الهاتف قصير جداً',
          'phone_number_too_long': 'رقم الهاتف طويل جداً',
          'invalid_phone_format': 'تنسيق رقم الهاتف غير صحيح',

          "phone_already_registered": "رقم الهاتف مسجّل مسبقاً",

          // رسائل التحقق - رقم الهاتف
          'phone_required': 'رقم الهاتف مطلوب',
          'phone_numbers_only': 'يجب إدخال أرقام فقط',
          'phone_invalid_length': 'رقم الهاتف يجب أن يكون 8 أرقام',
          'phone_max_length': 'رقم الهاتف يجب ألا يتجاوز 8 أرقام',

          // رسائل التحقق - كلمة المرور
          'password_required': 'كلمة المرور مطلوبة',

          // رسائل الخطأ
          'network_error': 'خطأ في الاتصال بالشبكة',
          'account_disabled': 'تم تعطيل الحساب',
          'empty_response': 'استجابة فارغة من الخادم',
          'invalid_token': 'رمز الوصول غير صالح',
          'invalid_user_data': 'بيانات المستخدم غير صالحة',

          'after': 'بعد',
          'tomorrow': 'غداً',

          'scheduled_time': 'الوقت المجدول',
        },
      };
}
