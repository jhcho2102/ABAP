@EndUserText.label : 'Object List Table - CDS'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table zobl_t001 {
  key mandt                 : mandt not null;
  key object                : trobjtype not null;
  key obj_name              : sobj_name not null;
  entityname                : ddstrucobjname;
  as4date                   : as4date;
  ddtext                    : ddtext;
  @EndUserText.label : 'Is Extended'
  is_extended               : abap.char(1);
  pack_name                 : devclass;
  compatibility_contract    : ars_release_contract;
  release_state             : ars_release_state;
  use_in_key_user_apps      : ars_use_in_key_user_apps;
  use_in_sap_cloud_platform : ars_use_in_sap_cp;
  @EndUserText.label : 'Has Source'
  has_source                : abap.char(1);

}
