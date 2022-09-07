prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_220100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2022.04.12'
,p_release=>'22.1.4'
,p_default_workspace_id=>9850767432578500
,p_default_application_id=>144
,p_default_id_offset=>0
,p_default_owner=>'TEST1'
);
end;
/
 
prompt APPLICATION 144 - APEX plugins
--
-- Application Export:
--   Application:     144
--   Name:            APEX plugins
--   Date and Time:   07:33 Wednesday September 7, 2022
--   Exported By:     DAVID
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 22731134659626726
--   Manifest End
--   Version:         22.1.4
--   Instance ID:     9750663202120450
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/region_type/glasgow_highchart_sankey
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(22731134659626726)
,p_plugin_type=>'REGION TYPE'
,p_name=>'GLASGOW-HIGHCHART-SANKEY'
,p_display_name=>'highchart-sankey'
,p_supported_ui_types=>'DESKTOP'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'----------------------------------------------------------------------------------',
'--',
'-- Renders a highCharts sankey chart using data returned from the SQL query.',
'--',
'-- Please note that commercial use of Highcharts requires a commercial license. ',
'-- For testing and demonstration purposes (POC), Highcharts can be used free of charge. ',
'-- Non-profit organisations, schools and personal websites are qualified for the free license. ',
'--',
'----------------------------------------------------------------------------------',
'function render(',
'  p_region              in apex_plugin.t_region,',
'  p_plugin              in apex_plugin.t_plugin,',
'  p_is_printer_friendly in boolean) return apex_plugin.t_region_render_result is',
'',
' begin',
' declare',
'    l_app     NUMBER := v (''APP_ID'');',
'    l_session NUMBER := v (''APP_SESSION'');',
'',
'    query_result          apex_plugin_util.t_column_value_list;',
'',
'    -- get the custon attributes to style the region',
'    chartName VARCHAR(100) := nvl(p_region.attribute_01, '''');',
'    seriesName VARCHAR(100) := nvl(p_region.attribute_02, '''');   ',
'    showCredits VARCHAR(100) := nvl(p_region.attribute_05, ''''); -- Y/N   ',
'    maxWidth integer := nvl(p_region.attribute_06, 800);',
'begin',
'  -- get the SQL source which we are going to insert into the JavaScript that renders the chart.',
'  query_result := apex_plugin_util.get_data (',
'    p_sql_statement      => p_region.source,',
'    p_min_columns        => 1,',
'    p_max_columns        => 20,',
'    p_component_name     => p_region.name); ',
'',
'    if showCredits = ''Y'' then',
'        showCredits := ''true'';',
'    else',
'        showCredits := ''false'';',
'    end if;',
'',
'-- include highchart libs',
'HTP.p (''<script src="https://code.highcharts.com/highcharts.js"></script>'');',
'HTP.p (''<script src="https://code.highcharts.com/highcharts-more.js"></script>'');',
'HTP.p (''<script src="https://code.highcharts.com/modules/sankey.js"></script>'');',
'HTP.p (''<script src="https://code.highcharts.com/modules/exporting.js"></script>'');',
'HTP.p (''<script src="https://code.highcharts.com/modules/export-data.js"></script>'');',
'HTP.p (''<script src="https://code.highcharts.com/modules/accessibility.js"></script>'');',
'',
'-- CSS to style the chart',
'HTP.p (''',
'<head>',
'<style>',
'.highcharts-figure,',
'.highcharts-data-table table {',
'    min-width: 310px;',
'    max-width: '' || maxWidth || ''px;',
'    margin: 1em auto;',
'}',
'',
'.highcharts-data-table table {',
'    font-family: Verdana, sans-serif;',
'    border-collapse: collapse;',
'    border: 1px solid #ebebeb;',
'    margin: 10px auto;',
'    text-align: center;',
'    width: 100%;',
'    max-width: 500px;',
'}',
'',
'.highcharts-data-table caption {',
'    padding: 1em 0;',
'    font-size: 1.2em;',
'    color: #555;',
'}',
'',
'.highcharts-data-table th {',
'    font-weight: 600;',
'    padding: 0.5em;',
'}',
'',
'.highcharts-data-table td,',
'.highcharts-data-table th,',
'.highcharts-data-table caption {',
'    padding: 0.5em;',
'}',
'',
'.highcharts-data-table thead tr,',
'.highcharts-data-table tr:nth-child(even) {',
'    background: #f8f8f8;',
'}',
'',
'.highcharts-data-table tr:hover {',
'    background: #f1f7ff;',
'}',
'</style>',
'</head>',
''');',
'',
'',
'-- this is where the chart will be displayed',
'HTP.p (''<figure class="highcharts-figure">',
'    <div id="container"></div>',
'    <p class="highcharts-description">',
'',
'    </p>',
'</figure>'');',
'',
'-- declare the chart and insert attributes',
'HTP.p (''<script>'');',
'HTP.p (''Highcharts.chart(''''container'''', {',
'',
'    title: {',
'        text: ''''''|| chartName|| ''''''',
'    },',
'    credits: {',
'        enabled: ''|| showCredits || ''',
'    },',
'  ',
'    series: [{',
'        keys: [''''from'''', ''''to'''', ''''weight''''],',
'        type: ''''sankey'''',',
'        name:  ''''''|| seriesName|| '''''',',
'        data: getData()',
'    }]',
'',
'});'');',
'',
'-- get the data fro SQL source and put it into JS code.',
'HTP.p (''function getData(){ var result = []; // array to pass to HighCharts'');',
'for rowNumber in query_result(1).first .. query_result(1).last loop  ',
'    HTP.p (''    result.push({'');',
'    HTP.p (''        from:''''''|| query_result(1)(rowNumber) || '''''',',
'                    to:''''''|| query_result(2)(rowNumber) || '''''',',
'                    weight:''|| query_result(3)(rowNumber) || ''});'');',
'end loop;',
'',
'HTP.p (''return result;'');',
'HTP.p (''}'');',
'HTP.p (''</script>'');',
'',
'return null;',
'end;',
'end;'))
,p_api_version=>2
,p_render_function=>'render'
,p_standard_attributes=>'SOURCE_LOCATION'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
,p_about_url=>'https://kjwvivmv0n5reuj-apexkqor.adb.uk-london-1.oraclecloudapps.com/ords/r/test1/apex-plugins/highchart-sankey'
,p_files_version=>24
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(22731306339626745)
,p_plugin_id=>wwv_flow_imp.id(22731134659626726)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Chart name'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_display_length=>100
,p_is_translatable=>false
,p_help_text=>'Will appear on the top of the chart.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(22731740490626748)
,p_plugin_id=>wwv_flow_imp.id(22731134659626726)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Series  name'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_help_text=>'Series name - will appear on tooltips'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(23327033306987741)
,p_plugin_id=>wwv_flow_imp.id(22731134659626726)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Show credit'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'Shows highchart credit at the bottom right of the chart.'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(23334079535390533)
,p_plugin_id=>wwv_flow_imp.id(22731134659626726)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Max width'
,p_attribute_type=>'INTEGER'
,p_is_required=>false
,p_unit=>'px'
,p_is_translatable=>false
,p_help_text=>'Maximum width of the chart (px). Defaults to 800'
);
wwv_flow_imp_shared.create_plugin_std_attribute(
 p_id=>wwv_flow_imp.id(22733283845626759)
,p_plugin_id=>wwv_flow_imp.id(22731134659626726)
,p_name=>'SOURCE_LOCATION'
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
