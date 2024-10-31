/*
Interesting patterns: https://docs.trellix.com/pt-PT/bundle/data-loss-prevention-11.10.x-classification-definitions-reference-guide/page/GUID-E8EA87D8-0C40-41C8-9308-AF08F00389D2.html#datalossprevention1110xclassificationdefinitionsreferenceguide-AdvancedPatternDefinitions-1
*/

delete ds_patterns where system_flag = 'Y';

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Banking', 'Currency code (sys)', 'Y', 'CHAR(3)'
  ,'(currency|ccy_|cur_).*(code|cd)', 'currency code', '', 'INT_CURRENCIES_170.CCY_CODE'
  ,90, 'OR', NULL
  ,'SQL',  q'#ds_masker_krn.random_value_from_data_set('INT_CURRENCIES_170.CCY_CODE',:col_data_length,ROWID)#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,remarks
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Banking', 'Belgian basic bank account number - BBAN (sys)', 'Y', 'CHAR(12)'
  ,'(bban)|((bank|account).*(no|nr|number|num|#))', 'Bank account number', '^[0-9]{3}([ -]?)[0-9]{7}\1(0[1-9]|[1-8][0-9]|9[0-7])$', ''
  ,NULL, 'OR', NULL
  ,'Belgian basic bank account number - BBAN'
  ,'SQL',  q'#ds_masker_krn.obfuscate_bban('BE',p_bban=>:column_name,p_seed=>:column_name)#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,remarks
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Banking', 'Visa card number (sys)', 'Y', 'CHAR(16)'
  ,'', '', '^4\d{3}([- ]?)\d{4}\1\d{4}\1\d{4}$', ''
  ,10, 'OR', NULL
  ,'Visa: starts with 4, followed by 12 or 15 additional digits'
  ,'SQL',  'ds_masker_krn.obfuscate_credit_card_number(p_number=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,remarks
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Banking', 'Mastercard card number (sys)', 'Y', 'CHAR(16)'
  ,'', '', '^5[1-5]\d{2}([- ]?)\d{4}\1\d{4}\1\d{4}$', ''
  ,10, 'OR', NULL
  ,'Mastercard: starts with 5, followed by 15 additional digits'
  ,'SQL',  'ds_masker_krn.obfuscate_credit_card_number(p_number=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,remarks
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Banking', 'American Express card number (sys)', 'Y', 'CHAR(15)'
  ,'', '', '^3[47]\d{2}([- ]?)\d{6}\1\d{5}$', ''
  ,10, 'OR', NULL
  ,'American Express: starts with 34 or 37, followed by 13 additional digits'
  ,'SQL',  'ds_masker_krn.obfuscate_credit_card_number(p_number=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,remarks
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Banking', 'Discover card number (sys)', 'Y', 'CHAR(16)'
  ,'', '', '^6011\d{2}([- ]?)\d{4}\1\d{4}\1\d{4}|65\d{2}\d{2}([- ]?)\d{4}\2\d{4}\2\d{4}|64[4-9]\d\d{2}([- ]?)\d{4}\3\d{3}\3\d{3}|6011\d{2}\d{2}([- ]?)\d{3}\4\d{3}\4\d{3}$', ''
  ,10, 'OR', NULL
  ,'Discover: starts with 6011 or 65, followed by 12 or 15 additional digits'
  ,'SQL',  'ds_masker_krn.obfuscate_credit_card_number(p_number=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,remarks
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Banking', 'Generic credit card number (sys)', 'Y', 'CHAR(15)'
  ,'cred.*card.*(number|nber|nbr|no|#)', 'credit.*card.*number', '^[0-9]{15,16}$', ''
  ,NULL, 'OR', NULL
  ,'Generic credit card number pattern'
  ,'SQL',  'ds_masker_krn.obfuscate_credit_card_number(p_number=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,remarks
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Banking', 'Expiry date (sys)', 'Y', 'DATE'
  ,'(expir).*(date|dt)', 'Expiry date', '', ''
  ,NULL , 'OR', NULL
  ,'Expiry date'
  ,'SQL',  'ds_masker_krn.random_expiry_date(p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,remarks
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Banking', 'SWIFT Code(sys)', 'Y', 'CHAR(8)'
  ,'(swift).*(code|cd)', 'SWIFT Code', '^[A-Z]{6}([A-Z0-9]{2}|[A-Z0-9]{5})$', ''
  ,NULL , 'OR', NULL
  ,'SWIFT Code (8 or 11 characters - format: first 6 char are [A-Z] and last 2 or 5 alphanumeric)'
  ,'SQL',  'ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Internet', 'E-mail address (sys)', 'Y', 'CHAR(10)'
  ,'(mail.*(from|to))|((^|_)(cc|bcc)($|_))', '', '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', ''
  ,90, 'OR', NULL
  ,'SQL',  'ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Internet', 'IP v4 address (sys)', 'Y', 'CHAR(7)'
  ,'', '', '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$', ''
  ,90, 'OR', NULL
  ,'SQL',  'ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Internet', 'IP v6 address (sys)', 'Y', 'CHAR(15)'
  ,'', '', '^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$', ''
  ,90, 'OR', NULL
  ,'SQL',  'ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Internet', 'URL (sys)', 'Y', 'CHAR(15)'
  ,'', '', '^(https?|ftp|file):\/\/([a-z0-9]+([\.\-][a-z0-9]+)*\.[a-z]{2,}|(\d{1,3}\.){3}\d{1,3})(:[0-9]{1,5})?(\/[^\s]*)?$', ''
  ,90, 'OR', NULL
  ,'SQL',  'ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Internet', 'Username (sys)', 'Y', 'CHAR(6)'
  ,'user.*(name|nm)', 'Username', '', ''
  ,NULL, 'OR', NULL
  ,'SQL',  'ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,remarks
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Personal', 'Identity card number (sys)', 'Y', 'CHAR(6)'
  ,'(identity|id).*(no|nr|number|num|#)', 'Identity card number', '^[0-9]{3}([ -]?)[0-9]{7}\1(0[1-9]|[1-8][0-9]|9[0-7])$', ''
  ,NULL, 'OR', NULL
  ,'Belgian identity card number - same format as a belgian bank account number'
  ,'SQL',  q'#ds_masker_krn.obfuscate_bban('BE',p_bban=>:column_name,p_seed=>:column_name)#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,remarks
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Personal', 'Belgian National Registration Number - NRN (sys)', 'Y', 'CHAR(10)'
  ,'(RRN|NRN|RSZ)|((be).*(nat).*(reg).*(no|nr|number|num|#))', 'National registration number', '^[0-9]{2}\.?(0[1-9]|1[0-2])\.?(0[1-9]|[12][0-9]|3[01])[ -]?[0-9]{3}[ .]?(0[1-9]|[1-8][0-9]|9[0-7])$', ''
  ,90, 'OR', NULL
  ,'Belgian National Registration Number - NRN'
  ,'SQL',  q'#ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,remarks
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Personal', 'Belgian Non-National Number (sys)', 'Y', 'CHAR(11)'
  ,'(be).*(non).*(nat).*(reg).*(no|nr|number|num|#)', 'Non-National registration number', '^[0-9]{2}\.?((2[1-9]|3[0-2]|4[1-9]|5[0-2])\.?(0[1-9]|[12][0-9]|3[01])|(00\.?00))[ -]?[0-9]{3}[ .]?(0[1-9]|[1-8][0-9]|9[0-7])$', ''
  ,90, 'OR', NULL
  ,'Belgian Non-National Registration Number (11-digit number, format is AA.BB.CC-DDD.EE)'
  ,'SQL',  q'#ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,remarks
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Personal', 'Belgian Passport Number (sys)', 'Y', 'CHAR(8)'
  ,'(be).*(passport).*(no|nr|number|num|#)', 'Belgian passport number', '^[A-Z]{2}\d{6}$', ''
  ,90, 'OR', NULL
  ,'Belgian Passport Number (format is CCNNNNNN)'
  ,'SQL',  q'#ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Personal', 'Phone number (sys)', 'Y', 'CHAR(6)'
  ,'((tele)?phone|(tele)?fax|gsm|mobile).*(no|nr|number|num|#)', '(tele)?phone|(tele)?fax|gsm|mobile number', '', ''
  ,NULL, 'OR', NULL
  ,'SQL',  q'#ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Personal', 'Gender - alpha (sys)', 'Y', 'CHAR(1)'
  ,'gender|sex', '', '^(M(ale)?|F(emale)?)$', ''
  ,90, 'OR', 1
  ,'SQL',  q'#CASE WHEN ds_masker_krn.random_integer(1,2) = 1 THEN 'M' ELSE 'F' END#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Personal', 'Gender - any type (sys)', 'Y', ''
  ,'(^|_)(sex|gender)(_|$)', '(^|\s|\W)(sex|gender)($|\s|\W)', '', ''
  ,90, 'OR', NULL
  ,'SQL',  2
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Personal', 'Person family name (sys)', 'Y', 'CHAR(15)'
  ,'((family|last|patronymic).*name)|surname|patronymic|cognomen', '', '', 'EU6_FAMILY_NAMES_217.FAMILY_NAME_ASCII'
  ,1, 'OR', NULL
  ,'SQL',  q'#ds_masker_krn.random_value_from_data_set('EU6_FAMILY_NAMES_217.FAMILY_NAME_ASCII',:col_data_length,ROWID)#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Personal', 'Person given name (sys)', 'Y', 'CHAR(15)'
  ,'((given|first|christian|baptismal|personal).*name)|forename', '', '', 'INT_GIVEN_NAMES_250.GIVEN_NAME_ASCII'
  ,5, 'OR', NULL
  ,'SQL',  q'#ds_masker_krn.random_value_from_data_set('INT_GIVEN_NAMES_250.GIVEN_NAME_ASCII',:col_data_length,ROWID)#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Personal', 'Person full name (sys)', 'Y', 'CHAR(15)'
  ,'((full|complete|entire|(first.*last)|person).*name)', '', '', ''
  ,NULL, NULL, NULL
  ,'SQL',  q'#SUBSTR(INITCAP(ds_masker_krn.random_value_from_data_set('INT_GIVEN_NAMES_250.GIVEN_NAME_ASCII',NULL,ROWID))||' '||UPPER(ds_masker_krn.random_value_from_data_set('EU6_FAMILY_NAMES_217.FAMILY_NAME_ASCII',NULL,ROWID)),1,:col_data_length)#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Personal', 'Person birth date (sys)', 'Y', 'DATE'
  ,'((birth|born).*(date|day))|((date|day).*(birth|born))', '', '', ''
  ,NULL, NULL, NULL
  ,'SQL',  'ds_masker_krn.random_date(p_min_date=>ADD_MONTHS(TRUNC(SYSDATE),-65*12),p_max_date=>ADD_MONTHS(TRUNC(SYSDATE),-21*12))'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Personal', 'Person death date (sys)', 'Y', 'DATE'
  ,'((death|decease|passing|demise).*(date|day))|((date|day).*(death|decease|passing|demise))', '', '', ''
  ,NULL, NULL, NULL
  ,'SQL',  'ds_masker_krn.random_date(p_min_date=>ADD_MONTHS(TRUNC(SYSDATE),-65*12),p_max_date=>ADD_MONTHS(TRUNC(SYSDATE),-21*12))'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Address', 'Country code alpha-2 (sys)', 'Y', 'CHAR(2)'
  ,'(country|ctry|cnt_).*(code|cd)', 'country code', '', 'INT_COUNTRIES_250.CTRY_CODE_A2'
  ,90, 'OR', NULL
  ,'SQL',  q'#ds_masker_krn.random_value_from_data_set('INT_COUNTRIES_250.CTRY_CODE_A2',:col_data_length,ROWID)#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Address', 'Country code alpha-3 (sys)', 'Y', 'CHAR(3)'
  ,'(country|ctry|cnt_).*(code|cd)', 'country code', '', 'INT_COUNTRIES_250.CTRY_CODE_A3'
  ,90, 'OR', NULL
  ,'SQL',  q'#ds_masker_krn.random_value_from_data_set('INT_COUNTRIES_250.CTRY_CODE_A3',:col_data_length,ROWID)#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Address', 'Postal code (sys)', 'Y', 'CHAR(4)'
  ,'((zip|post|postal|pin).*(code|cd))', '', '', ''
  ,NULL, NULL, NULL
  ,'SQL',  'ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Address', 'Street (sys)', 'Y', 'CHAR(10)'
  ,'street|road|way', '', '', ''
  ,NULL, NULL, NULL
  ,'SQL',  'ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Address', 'Address (sys)', 'Y', 'CHAR(2)'
  ,'address|residence|location', '', '', ''
  ,NULL, NULL, NULL
  ,'SQL',  'ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Address', 'State (sys)', 'Y', 'CHAR(10)'
  ,'((^|_)state(_|$))|province', '', '', ''
  ,NULL, NULL, NULL
  ,'SQL',  'ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Address', 'City (sys)', 'Y', 'CHAR(10)'
  ,'(^|_)(city|cty|town|municipality|place)(_|$)', '(^|\s|\W)city|town|municipality|place($|\s|\W)', '', 'EU_MAJOR_CITIES_590.CTY_NAME_ASCII'
  ,5, 'OR', NULL
  ,'SQL',  q'#ds_masker_krn.random_value_from_data_set('EU_MAJOR_CITIES_590.CTY_NAME_ASCII',:col_data_length,ROWID)#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Vehicle', 'Registration(sys)', 'Y', 'CHAR(6)'
  ,'(^|_)plate(_|$)', '', '', ''
  ,NULL, NULL, NULL
  ,'SQL',  'ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Vehicle', 'Vehicle id (sys)', 'Y', 'CHAR(2)'
  ,'vehicle*.(id|n(um)?ber)', '', '', ''
  ,NULL, NULL, NULL
  ,'SQL',  'ds_masker_krn.obfuscate_string(p_string=>:column_name,p_seed=>:column_name)'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Large text', 'Large text (sys)', 'Y', 'CHAR(400)'
  ,'', '', '', ''
  ,NULL, NULL, NULL
  ,'SQL',  q'#ds_masker_krn.lorem_ipsum_text(LENGTH(:column_name))#'
);

insert into ds_patterns (
   pat_id, pat_cat, pat_name, system_flag, col_data_type
  ,col_name_pattern, col_comm_pattern, col_data_pattern, col_data_set_name
  ,col_data_min_pct, logical_operator, pat_seq
  ,msk_type, msk_params
) values (
   ds_pat_seq.nextval, 'Large text', 'Very large text (sys)', 'Y', 'CLOB'
  ,'', '', '', ''
  ,NULL, NULL, NULL
  ,'SQL',  q'#ds_masker_krn.lorem_ipsum_text(LENGTH(:column_name))#'
);

COMMIT;
