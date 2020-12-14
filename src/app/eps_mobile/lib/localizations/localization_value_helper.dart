import 'package:eps_mobile/helpers/enum_helper.dart';
import 'package:eps_mobile/models/localization_key_values.dart';
import 'package:eps_mobile/models/localization.dart';

class LocalizationValueHelper {
  var _valueMapping = Map<Localization, Map<String, String>>();

  var _englishLocalization = Localization('en', 'English');
  var _espanolLocalization = Localization('es', 'Espanol');
  var _francaisLocalization = Localization('fr', 'Francais');

  LocalizationValueHelper() {
    _initData();
  }

  List<Localization> getAllLocalizations() {
    var localizations = List<Localization>();
    for (var item in _valueMapping.entries) {
      localizations.add(item.key);
    }
    return localizations;
  }

  Localization getEnglishLocalization() {
    return _englishLocalization;
  }

  Localization getEspanolLocalization() {
    return _espanolLocalization;
  }

  Localization getFrancaisLocalization() {
    return _francaisLocalization;
  }

  String getValue(
    Localization localization,
    String key,
  ) {
    if (_valueMapping.containsKey(localization)) {
      if (_valueMapping[localization].containsKey(key)) {
        return _valueMapping[localization][key];
      }
    }
    return '';
  }

  String getValueFromEnum(
    Localization localization,
    LocalizationKeyValues key,
  ) {
    var keyString = EnumHelper.enumToString(key);
    return getValue(
      localization,
      keyString,
    );
  }

  void _addValueSet(
    LocalizationKeyValues localizationKeyValue,
    String english,
    String espanol,
    String francais,
  ) {
    _valueMapping[_englishLocalization]
        [EnumHelper.enumToString(localizationKeyValue)] = english;
    _valueMapping[_espanolLocalization]
        [EnumHelper.enumToString(localizationKeyValue)] = espanol;
    _valueMapping[_francaisLocalization]
        [EnumHelper.enumToString(localizationKeyValue)] = francais;
  }

  void _initData() {
    // Init Data (Fixed Data Set)
    _valueMapping[_englishLocalization] = Map<String, String>();
    _valueMapping[_espanolLocalization] = Map<String, String>();
    _valueMapping[_francaisLocalization] = Map<String, String>();

    _addValueSet(
      LocalizationKeyValues.APP_NAME,
      'EPS Mobile',
      'EPS Móvil',
      'EPS Mobile',
    );

    _addValueSet(
      LocalizationKeyValues.USERNAME,
      'Username',
      'Nombre de usuario',
      'Nom d\'utilisateur',
    );

    _addValueSet(
      LocalizationKeyValues.PASSWORD,
      'Password',
      'Contraseña',
      'Mot de passe',
    );

    _addValueSet(
      LocalizationKeyValues.SIGN_IN,
      'Sign In',
      'Registrarse', // translates to "Check in"
      'Se connecter', // translates to "To log in"
    );

    _addValueSet(
      LocalizationKeyValues.REQUEST_PASSWORD_RESET,
      'Request Password Reset',
      'Petición para la recuperación de contraseña', // translates to "Request for password recovery"
      'Demander la réinitialisation du mot de passe',
    );

    _addValueSet(
      LocalizationKeyValues.SETTINGS,
      'Settings',
      'Configuraciones', // translates to "Congigurations"
      'Réglages',
    );

    _addValueSet(
      LocalizationKeyValues.API_URL,
      'API URL',
      'API URL',
      'API URL',
    );

    _addValueSet(
      LocalizationKeyValues.SAVE,
      'Save',
      'Salvar',
      'sauver', // translates to "To save"
    );

    _addValueSet(
      LocalizationKeyValues.THIS_MUST_BE_A_VALID_URL,
      'This must be a valid url',
      'Esta debe ser una url válida',
      'Ce doit être une URL valide', // translates to "Must be a valid URL"
    );

    _addValueSet(
      LocalizationKeyValues.INCORRECT_USERNAME_EMAIL_OR_PASSWORD,
      'Incorrect username/email or password',
      'Nombre de usuario / dirección de correo electrónico o contraseña incorrectos', // translates to "Incorrect username / email address or password"
      'Le courriel / nom d\'utilisateur ou le mot de passe saisi est incorrect', // translates to "Incorrect email / username or password entered"
    );

    _addValueSet(
      LocalizationKeyValues.SYNCING,
      'Syncing',
      'Sincronización', // translates to "Synchronization"
      'Synchronisation', // translates to "Synchronization"
    );

    _addValueSet(
      LocalizationKeyValues.UNAUTHORIZED,
      'Unauthorized',
      'No autorizado', // translates to "Not authorized"
      'Non autorisé',
    );

    _addValueSet(
      LocalizationKeyValues.YOU_ARE_NOT_AUTHORIZED_TO_ACCESS_THIS_VIEW,
      'You are not authorized to access this view',
      'No tiene autorización para acceder a esta vista',
      'Vous n\'êtes pas autorisé à accéder à cette vue', // translates to ""
    );

    _addValueSet(
      LocalizationKeyValues.CASE_TYPES,
      'Case Types',
      'Tipos de casos', // translates to "Types of cases"
      'Types de cas',
    );

    _addValueSet(
      LocalizationKeyValues.EMAIL,
      'Email',
      'Correo electrónico',
      'Email', // translates to "E-mail"
    );

    _addValueSet(
      LocalizationKeyValues.REQUEST,
      'Request',
      'Solicitud',
      'Demande',
    );

    _addValueSet(
      LocalizationKeyValues.EMAIL_CAN_NOT_CONTAIN_SPACES,
      'Email can not contain spaces',
      'El correo electrónico no puede contener espacios',
      'L\'email ne peut pas contenir d\'espaces',
    );

    _addValueSet(
      LocalizationKeyValues.EMAIL_CAN_NOT_BE_BLANK,
      'Email can not be blank',
      'El correo electrónico no puede estar en blanco',
      'L\'email ne peut pas être vide', // translates to "Email can not be empty"
    );

    _addValueSet(
      LocalizationKeyValues.MUST_BE_A_VALID_EMAIL,
      'Must be a valid email',
      'Debe ser un correo electrónico válido',
      'Doit être un e-mail valide',
    );

    _addValueSet(
      LocalizationKeyValues.NO_CONNECTIVITY_PLEASE_TRY_AGAIN_LATER,
      'No connectivity, please try again later',
      'No hay conectividad, intente nuevamente más tarde',
      'Aucune connectivité, veuillez réessayer plus tard',
    );

    _addValueSet(
      LocalizationKeyValues
          .AN_EMAIL_WITH_INSTRUCTIONS_TO_RESET_YOUR_PASSWORD_HAS_BEEN_SENT_TO_YOU,
      'An email with instructions to reset your password has been sent to you',
      'Se le ha enviado un correo electrónico con instrucciones para restablecer su contraseña.', // translates to "An email has been sent to you with instructions on how to reset your password."
      'Un e-mail contenant des instructions pour réinitialiser votre mot de passe vous a été envoyé',
    );

    _addValueSet(
      LocalizationKeyValues.AN_ERROR_OCCURRED_PLEASE_TRY_AGAIN_LATER,
      'An error occurred please try again later',
      'Se produjo un error. Vuelve a intentarlo más tarde.', // translates to "There was an error. Try again later."
      'Une erreur s\'est produite, veuillez réessayer plus tard', // translates to "An error has occurred, please try again later"
    );

    _addValueSet(
      LocalizationKeyValues.DISMISS,
      'Dismiss',
      'Descartar', // translates to "Discard"
      'Rejeter', // translates to "To Reject"
    );

    _addValueSet(
      LocalizationKeyValues.PROJECT_INFO,
      'Project Info',
      'Información del proyecto', // translates to "Project information"
      'Infos sur le projet',
    );

    _addValueSet(
      LocalizationKeyValues.CASES,
      'Cases',
      'Casos',
      'Étuis',
    );

    _addValueSet(
      LocalizationKeyValues.SURVEYS,
      'Surveys',
      'Encuestas', // translates to "Polls"
      'Enquêtes', // translates to "Investigations"
    );

    _addValueSet(
      LocalizationKeyValues.SYNC,
      'Sync',
      'Sincronización', // translates to "Synchronization"
      'Sync',
    );

    _addValueSet(
      LocalizationKeyValues
          .UNABLE_TO_GO_ONLINE_PLEASE_CHECK_YOUR_INTERNET_CONNECTION,
      'Unable to go online, please check you internet connection',
      'Incapaz de conectarse, verifique su conexión a Internet', // translates to "Unable to connect, check your internet connection"
      'Impossible de se connecter, veuillez vérifier votre connexion Internet', // translates to "Unable to connect, please check your Internet connection"
    );

    _addValueSet(
      LocalizationKeyValues.YOU_ARE_NOW_IN_ONLINE_MODE,
      'You are now in online mode',
      'Ahora estás en modo en línea',
      'Vous êtes maintenant en mode en ligne',
    );

    _addValueSet(
      LocalizationKeyValues.YOU_ARE_NOW_IN_OFFLINE_MODE,
      'You are now in offline mode. Sync is unavailable due to poor internet connection. Please return to online mode when you find a stable connection',
      'Ahora estás en modo fuera de línea. La sincronización no está disponible debido a una mala conexión a Internet. Regrese al modo en línea cuando encuentre una conexión estable', // translates to "You are now in offline mode. Synchronization is not available due to a poor Internet connection. Return to online mode when you find a stable connection  "
      'Vous êtes maintenant en mode hors ligne. La synchronisation n\'est pas disponible en raison d\'une mauvaise connexion Internet. Veuillez revenir en mode en ligne lorsque vous trouvez une connexion stable', // translates to "You are now in offline mode. Synchronization is not available due to a bad Internet connection. Please return to online mode when you find a stable connection"
    );

    _addValueSet(
      LocalizationKeyValues.ONLINE,
      'Online',
      'En línea',
      'En ligne',
    );

    _addValueSet(
      LocalizationKeyValues.OFFLINE,
      'Offline',
      'Desconectado', // translates to "Disconnected"
      'Hors ligne',
    );

    _addValueSet(
      LocalizationKeyValues.SIGN_OUT,
      'Sign Out',
      'Desconectar', // translates to "Disconnect"
      'Déconnexion', // translates to "Logout"
    );

    _addValueSet(
      LocalizationKeyValues.ID,
      'ID',
      'ID', // abbreviation
      'ID', // abbreviation
    );

    _addValueSet(
      LocalizationKeyValues.LAST_UPDATED_AT,
      'Last Updated At',
      'Última actualización en', // translates to "Last update on"
      'Dernière mise à jour à', // translates to "Last update at"
    );

    _addValueSet(
      LocalizationKeyValues.CREATED_AT,
      'Created At',
      'Creado en', // translates to "Created in"
      'Créé à',
    );

    _addValueSet(
      LocalizationKeyValues.ARCHIVE_RESPONSE_QUESTION_TITLE,
      'Archive Response?',
      'Archivo de respuesta?', // translates to "Answer file?"
      'Réponse de l\'archive?', // translates to "Response from the archive?"
    );

    _addValueSet(
      LocalizationKeyValues.ARE_YOU_SURE_YOU_WANT_TO_ARCHIVE_THIS_RESPONSE,
      'Are you sure you want to archive this response?',
      '¿Estás seguro de que deseas archivar esta respuesta?', // translates to "Are you sure you want to archive this answer?"
      'Voulez-vous vraiment archiver cette réponse?',
    );

    _addValueSet(
      LocalizationKeyValues.OK,
      'OK',
      'Okay',
      'D\'accord', // translates to "Okay"
    );

    _addValueSet(
      LocalizationKeyValues.CANCEL,
      'Cancel',
      'Cancelar',
      'Annuler', // translates to "To cancel"
    );

    _addValueSet(
      LocalizationKeyValues.ERROR_ARCHIVING_RESPONSE,
      'Error Archiving Response',
      'Error al archivar la respuesta', // translates to "Failed to archive response"
      'Réponse d\'archivage d\'erreur',
    );

    _addValueSet(
      LocalizationKeyValues.SUBMIT,
      'Submit',
      'Enviar', // translates to "Send"
      'Soumettre',
    );

    _addValueSet(
      LocalizationKeyValues.SAVE_CHANGES_QUESTION_TITLE,
      'Save Changes?',
      '¿Guardar cambios?',
      'Sauvegarder les modifications?',
    );

    _addValueSet(
      LocalizationKeyValues.CHANGES_MADE_MAY_NOT_BE_SAVED,
      'Changes made may not be saved',
      'Los cambios realizados no pueden guardarse', // translates to "Changes made cannot be saved"
      'Les modifications apportées peuvent ne pas être enregistrées',
    );

    _addValueSet(
      LocalizationKeyValues.EXIT,
      'Exit',
      'Salida', // translates to "Departure"
      'Sortie',
    );

    _addValueSet(
      LocalizationKeyValues.NAME,
      'Name',
      'Nombre',
      'Nom', // translates to "Last Name"
    );

    _addValueSet(
      LocalizationKeyValues.TITLE,
      'Title',
      'Título',
      'Titre', // translates to "Headline"
    );

    _addValueSet(
      LocalizationKeyValues.ORGANIZATION,
      'Organization',
      'Organización',
      'Organisation',
    );

    _addValueSet(
      LocalizationKeyValues.LOCATION,
      'Location',
      'Ubicación',
      'Emplacement',
    );

    _addValueSet(
      LocalizationKeyValues.FUNDING_AMOUNT,
      'Funding Amount',
      'Monto de Financiamiento', // translates to "Financing Amount"
      'Montant du financement',
    );

    _addValueSet(
      LocalizationKeyValues.AGREEMENT_NUMBER,
      'Agreement Number',
      'Numero de acuerdo',
      'Numéro d\'agrément', // translates to "Approval number"
    );

    _addValueSet(
      LocalizationKeyValues.START_DATE,
      'Start Date',
      'Fecha de inicio',
      'Date de début',
    );

    _addValueSet(
      LocalizationKeyValues.END_DATE,
      'End Date',
      'Fecha final', // translates to "Final date"
      'Date de fin',
    );

    _addValueSet(
      LocalizationKeyValues.PROFILE,
      'Profile',
      'Perfil',
      'Profil',
    );

    _addValueSet(
      LocalizationKeyValues.CHANGE_USERNAME,
      'Change Username',
      'Cambie el nombre de usuario',
      'Changer le nom d\'utilisateur',
    );

    _addValueSet(
      LocalizationKeyValues.CHANGE_EMAIL,
      'Change Email',
      'Cambiar e-mail',
      'Changer l\'e-mail',
    );

    _addValueSet(
      LocalizationKeyValues.CHANGE_PASSWORD,
      'Change Password',
      'Cambia la contraseña',
      'Changer le mot de passe', // translates to "to change the password"
    );

    _addValueSet(
      LocalizationKeyValues.TAKE_A_PICTURE,
      'Take a picture',
      'Toma una foto', // translates to "Take a photo"
      'Prendre une photo', // translates to "To take a picture"
    );

    _addValueSet(
      LocalizationKeyValues.USE_THIS_PICTURE,
      'Use this Picture?',
      '¿Usa esta foto?', // translates to "Do you use this photo?"
      'Utilise cette photo?',
    );

    _addValueSet(
      LocalizationKeyValues.CLOSE,
      'Close',
      'Cerca', // translates to "Near"
      'Proche',
    );

    _addValueSet(
      LocalizationKeyValues.DESCRIPTION,
      'Description',
      'Descripción',
      'La description', // translates to "The description"
    );

    _addValueSet(
      LocalizationKeyValues.OLD_USERNAME,
      'Old Username',
      'Nombre de usuario anterior', // translates to "Previous username"
      'Ancien nom d\'utilisateur', // translates to ""
    );

    _addValueSet(
      LocalizationKeyValues.NEW_USERNAME,
      'New Username',
      'Nuevo nombre de usuario',
      'Nouveau nom d\'utilisateur',
    );

    _addValueSet(
      LocalizationKeyValues.CHANGE,
      'Change',
      'Cambio',
      'Changement',
    );

    _addValueSet(
      LocalizationKeyValues.CAN_NOT_BE_OLD_USERNAME,
      'Can not be old username',
      'No puede ser antiguo nombre de usuario',
      'Ne peut pas être un ancien nom d\'utilisateur', // translates to "Cannot be an old username"
    );

    _addValueSet(
      LocalizationKeyValues.USERNAME_CAN_NOT_CONTAIN_SPACES,
      'Username can not contain spaces',
      'El nombre de usuario no puede contener espacios',
      'Le nom d\'utilisateur ne peut pas contenir d\'espaces',
    );

    _addValueSet(
      LocalizationKeyValues.USERNAME_CAN_NOT_BE_BLANK,
      'Username can not be blank',
      'nombre de usuario no puede estar en blanco',
      'Le nom d\'utilisateur ne peut pas être vide', // translates to "Username cannot be empty"
    );

    _addValueSet(
      LocalizationKeyValues.CHARACTERS,
      'characters',
      'caracteres',
      'personnages',
    );

    _addValueSet(
      LocalizationKeyValues.USERNAME_MUST_BE_AT_LEAST,
      'Username must be at least',
      'El nombre de usuario debe ser al menos',
      'Le nom d\'utilisateur doit être au moins',
    );

    _addValueSet(
      LocalizationKeyValues.USERNAME_CAN_NOT_BE_MORE_THAN,
      'Username can not be more than',
      'El nombre de usuario no puede ser más que', // translates to "The username cannot be more than"
      'Le nom d\'utilisateur ne peut pas dépasser', // translates to "Username cannot exceed"
    );

    _addValueSet(
      LocalizationKeyValues.YOUR_USERNAME_HAS_BEEN_CHANGED,
      'Your username has been changed',
      'Su nombre de usuario ha sido cambiado',
      'Votre nom d\'utilisateur a été changé',
    );

    _addValueSet(
      LocalizationKeyValues.ERROR,
      'Error',
      'Error',
      'Erreur', // translates to "Fault"
    );

    _addValueSet(
      LocalizationKeyValues.OLD_EMAIL,
      'Old Email',
      'Correo electrónico viejo',
      'Ancien e-mail',
    );

    _addValueSet(
      LocalizationKeyValues.NEW_EMAIL,
      'New Email',
      'Nuevo Email',
      'Nouveau courrielNouveau courrielNouveau courriel',
    );

    _addValueSet(
      LocalizationKeyValues.CAN_NOT_BE_OLD_EMAIL,
      'Can not be old email',
      'No puede ser correo electrónico antiguo', // translates to "It can't be old email"
      'Ne peut pas être un ancien e-mail', // translates to "Cannot be an old email"
    );

    _addValueSet(
      LocalizationKeyValues.EMAIL_MUST_BE_AT_LEAST,
      'Email must be at least',
      'El correo electrónico debe ser al menos',
      'L\'email doit être au moins', // translates to "The email must be at least"
    );

    _addValueSet(
      LocalizationKeyValues.EMAIL_CAN_NOT_BE_MORE_THAN,
      'Email can not be more than',
      'El correo electrónico no puede ser más que', // translates to "Email can only be"
      'L\'email ne peut pas dépasser', // translates to "Email cannot exceed"
    );

    _addValueSet(
      LocalizationKeyValues.YOUR_EMAIL_HAS_BEEN_CHANGED,
      'Your email has been changed',
      'Su correo ha sido cambiado',
      'Votre email a été changé',
    );

    _addValueSet(
      LocalizationKeyValues.NEW_PASSWORD,
      'New Password',
      'Nueva contraseña',
      'nouveau mot de passe',
    );

    _addValueSet(
      LocalizationKeyValues.SHOW,
      'Show',
      'mostrar', // translates to "to show"
      'Spectacle',
    );

    _addValueSet(
      LocalizationKeyValues.CONFIRM_NEW_PASSWORD,
      'Confirm New Password',
      'Confirmar nueva contraseña',
      'Confirmer le nouveau mot de passe',
    );

    _addValueSet(
      LocalizationKeyValues.NEW_PASSWORDS_MUST_MATCH,
      'New passwords must match',
      'Las nuevas contraseñas deben coincidir',
      'Les nouveaux mots de passe doivent correspondre',
    );

    _addValueSet(
      LocalizationKeyValues.PASSWORDS_MUST_BE_AT_LEAST,
      'Passwords must be at least',
      'Las contraseñas deben ser al menos',
      'Les mots de passe doivent être au moins',
    );

    _addValueSet(
      LocalizationKeyValues.PASSWORDS_CAN_NOT_BE_MORE_THAN,
      'Passwords can not be more than',
      'Las contraseñas no pueden ser más que',
      'Les mots de passe ne peuvent pas dépasser', // translates to "Passwords cannot exceed"
    );

    _addValueSet(
      LocalizationKeyValues.PASSWORD_CONTAIN_UPPER,
      'Password must contain at least 1 upper case letter',
      'La contraseña debe contener al menos 1 letra mayúscula', // translates to "Password must contain at least 1 capital letter"
      'Le mot de passe doit contenir au moins 1 lettre majuscule', // translates to "Password must contain at least 1 capital letter"
    );

    _addValueSet(
      LocalizationKeyValues.PASSWORD_CONTAIN_LOWER,
      'Password must contain at least 1 lower case letter',
      'La contraseña debe contener al menos 1 letra minúscula',
      'Le mot de passe doit contenir au moins 1 lettre minuscule',
    );

    _addValueSet(
      LocalizationKeyValues.PASSWORD_CONTAIN_NUMBER,
      'Password must contain at least 1 number',
      'La contraseña debe contener al menos 1 número',
      'Le mot de passe doit contenir au moins 1 chiffre', // translates to "Password must contain at least 1 digit"
    );

    _addValueSet(
      LocalizationKeyValues.PASSWORD_CONTAIN_SPECIAL,
      'Password must contain at least 1 special character',
      'La contraseña debe contener al menos 1 carácter especial',
      'Le mot de passe doit contenir au moins 1 caractère spécial',
    );

    _addValueSet(
      LocalizationKeyValues.YOUR_PASSWORD_HAS_BEEN_CHANGED,
      'Your password has been changed',
      'Tu contraseña ha sido cambiada',
      'votre mot de passe a été changé',
    );

    _addValueSet(
      LocalizationKeyValues.ADD_NEW_CASE,
      'Add New Case',
      'Añadir nuevo caso',
      'Ajouter un nouveau cas',
    );

    _addValueSet(
      LocalizationKeyValues.NEW_CASE,
      'New Case',
      'Nuevo caso',
      'Nouveau cas',
    );

    _addValueSet(
      LocalizationKeyValues.CASE_INSTANCE,
      'Case Instance',
      'Instancia de caso', // translates to "Instance of case"
      'Instance de cas', // translates to "Case Proceeding"
    );

    _addValueSet(
      LocalizationKeyValues.EDIT,
      'Edit',
      'Editar',
      'Éditer',
    );

    _addValueSet(
      LocalizationKeyValues.STATUS,
      'Status',
      'Estado', // translates to "State"
      'Statut',
    );

    _addValueSet(
      LocalizationKeyValues.CASE_DOCUMENTS,
      'Case Documents',
      'Documentos de caso',
      'Documents de cas',
    );

    _addValueSet(
      LocalizationKeyValues.ATTACHMENTS,
      'Attachments',
      'Archivos adjuntos', // translates to "Attached Files"
      'Pièces jointes',
    );

    _addValueSet(
      LocalizationKeyValues.ADD_FILE,
      'Add File',
      'Agregar archivo',
      'Ajouter le fichier',
    );

    _addValueSet(
      LocalizationKeyValues.NOTES,
      'Notes',
      'Notas',
      'Remarques', // translates to "Remarks"
    );

    _addValueSet(
      LocalizationKeyValues.ADD_NOTE,
      'Add Note',
      'Añadir la nota',
      'Ajouter une note', // translates to ""
    );

    _addValueSet(
      LocalizationKeyValues.REQUIRED,
      'required',
      'necesario', // translates to "necessary"
      'obligatoire', // translates to "obligatory"
    );

    _addValueSet(
      LocalizationKeyValues.EDIT_CASE,
      'Edit Case',
      'Editar caso',
      'Modifier le cas', // translates to "Modify the case"
    );

    _addValueSet(
      LocalizationKeyValues.ADD_CASE_NOTE,
      'Add Case Note',
      'Agregar nota de caso',
      'Ajouter une note de cas', // translates to "Add a case note"
    );

    _addValueSet(
      LocalizationKeyValues.DELETE_FILE_QUESTION_TITLE,
      'Delete File?',
      '¿Borrar archivo?',
      'Supprimer le fichier?',
    );

    _addValueSet(
      LocalizationKeyValues.DELETE_FILE_QUESTION_TITLE,
      'Are you sure you want to delete this file?',
      '¿Estás seguro de que quieres eliminar este archivo?',
      'Voulez-vous vraiment supprimer ce fichier?',
    );

    _addValueSet(
      LocalizationKeyValues.CAN_NOT_DELETE_IN_OFFLINE_MODE,
      'Can not delete in offline mode',
      'No se puede eliminar en modo fuera de línea', // translates to "Cannot be removed in offline mode"
      'Impossible de supprimer en mode hors ligne', // translates to "Unable to delete in offline mode"
    );

    _addValueSet(
      LocalizationKeyValues.NO_CASES_FOUND,
      'No Cases Found',
      'No se encontraron casos', // translates to "No cases were found"
      'Aucun cas trouvé',
    );

    _addValueSet(
      LocalizationKeyValues.CAN_NOT_BE_BLANK,
      'Can not be blank',
      'No puede estar en blanco',
      'Ne peut être vide', // translates to "Cannot be empty"
    );

    _addValueSet(
      LocalizationKeyValues.CAN_NOT_BE_ALL_SPACES,
      'Can not be all spaces',
      'No pueden ser todos los espacios', // translates to "It can't be all the spaces"
      'Ne peut pas être tous les espaces',
    );

    _addValueSet(
      LocalizationKeyValues.MUST_SELECT_AT_LEAST_ONE,
      'Must select at least one',
      'Debe seleccionar al menos uno', // translates to "You must select at least one"
      'Doit sélectionner au moins un',
    );

    _addValueSet(
      LocalizationKeyValues.PICK_DATE,
      'Pick Date',
      'Fecha de Pick',
      'Choisir la date', // translates to "Choose the date"
    );

    _addValueSet(
      LocalizationKeyValues.CLEAR,
      'Clear',
      'Claro',
      'Clair',
    );

    _addValueSet(
      LocalizationKeyValues.THIS_IS_NOT_A_NUMBER,
      'This is not a number',
      'Este no es un numero',
      'Ce n\'est pas un nombre', // translates to "It's not a number"
    );

    _addValueSet(
      LocalizationKeyValues.CLEAR_SELECTION,
      'Clear Selection',
      'Selección clara',
      'Effacer la sélection',
    );

    _addValueSet(
      LocalizationKeyValues.MUST_MAKE_A_SELECTION,
      'Must make a selection',
      'Debe hacer una selección', // translates to "You must make a selection"
      'Doit faire une sélection',
    );

    _addValueSet(
      LocalizationKeyValues.DELETE_CASE,
      'Delete Case?',
      '¿Eliminar caso?',
      'Supprimer le cas?', // translates to "Delete the case?"
    );

    _addValueSet(
      LocalizationKeyValues.DELETE_CASE_ARE_YOU_SURE,
      'Are you sure you want to delete this case?',
      '¿Estás seguro de que deseas eliminar este caso?',
      'Voulez-vous vraiment supprimer ce cas?',
    );

    _addValueSet(
      LocalizationKeyValues.YES,
      'Yes',
      'Si',
      'Oui',
    );

    _addValueSet(
      LocalizationKeyValues.NO,
      'No',
      'No',
      'Non',
    );

    _addValueSet(
      LocalizationKeyValues.LOADING,
      'Loading',
      'Cargando',
      'Chargement',
    );

    _addValueSet(
      LocalizationKeyValues.ASSIGNED_TO,
      'Assigned To',
      'Asignado a',
      'Assigné à',
    );

    _addValueSet(
      LocalizationKeyValues.TAP_TO_CHANGE_ASSIGNMENT,
      'tap to change assignment',
      'toque para cambiar la asignación',
      'appuyez pour modifier l\'attribution',
    );

    // NEW ENTRY //
    // _addValueSet(
    //   LocalizationKeyValues.TEMP,
    //   '',
    //   '', // translates to ""
    //   '', // translates to ""
    // );
    // NEW //
  }
}
