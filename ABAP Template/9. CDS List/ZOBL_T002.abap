@EndUserText.label : 'Object List Table - CDS Elements'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #ALLOWED
define table zobl_t002 {
  key mandt        : mandt not null;
  key entity_name  : sobj_name not null;
  key element_name : fieldname not null;
  base_object      : objectname;
  base_field       : fieldname;
  is_calculated    : dd_cds_calculated;

}
