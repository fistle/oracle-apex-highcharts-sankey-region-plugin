# oracle-apex-highcharts-sankey-region-plugin

Add a High chart sankey chart to your Oracle APEX app.

Data points defined in the SQL query, chart options defined in attributes

Tested on APEX version 22.1

Please note that commercial use of Highcharts requires a commercial license. For testing and demonstration purposes (POC), Highcharts can be used free of charge. Non-profit organisations, schools and personal websites are qualified for the free license. 

Instructions
-------------------------------
Install the plugin - Shared Components->plugins->import
Create a new region with type highcharts-sankey
Change source type to SQL Query then copy the demo SQL in.
You can leave attributes blank to start as it will use default settings.

Attributes
-------------------------------
Chart name - empty shows no title
Series name - empty shows no series name
Show credits - false to remove credits on bottom right

Demo SQL
-------------------------------
select 'Brazil', 'Portugal',5 from DUAL
UNION
select 'Brazil', 'France',5 from DUAL
UNION
select 'Brazil', 'Spain',1 from DUAL
UNION
select 'Brazil', 'England',1 from DUAL
UNION
select 'Canada', 'Portugal',1 from DUAL
UNION
select 'Canada', 'France',5 from DUAL
UNION
select 'Canada', 'England',5 from DUAL
UNION
select 'Mexico', 'Portugal',5 from DUAL
UNION
select 'Mexico', 'France',5 from DUAL
UNION
select 'Mexico', 'Spain',5 from DUAL
UNION
select 'Mexico', 'England',5 from DUAL
