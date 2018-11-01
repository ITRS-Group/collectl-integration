# CollectL Plugin Configuration

In this tutorial, we will enable CollectL and visualize the results in the Active Console. At this point, you should have installed CollectL software including the documentation and ITRS script provided.

### Using CollectL to Generate Data
CollectL can be used to generate data in three different ways, either brief, verbose, or detailed. In addition, the user can specify a script with pre-defined configuration and received the desired pre-formatted output. 

The ITRS script provided, namely itrs.ph, contains pre-formatted output and configuration parameters. It’s also configured to support CPU, Network, Process, Memory, and Infiniband statistics.
For example, simply running the following command will generate the proper output for the statistics specified:

``   collectl -sCN –export itrs                              (for CPU and Network Stats)
``

### Building Your Dataview Using an IX-MA Sampler
Now that you have the stats generated into the appropriate files, let’s configure a new IX-MA sampler to display the information.

Configuring the IX-MA sampler is very simple once you determine the format of your data.

In this example, our output will be formatted as a comma-separated file for both CPU and Network.


1. Create a new IX-MA Sampler and click ‘Add New’ under Adapters section.

2. Select Text and click ‘Text Adapter’.  

  a. Source – leave this blank

3. In Trackers section, select fieldValue under ‘options’ and click ‘Field Value Tracker’.

   a. Name – create a specific name (ex. MyCpu ) for reference

   b. Filter – set to ‘ALL’ to include all characters
   
   c. Field Name – specify field position (ex. field_1 , for first position in row data)
   
   d. Repeat Step 3 for each significant field in row data

4. Add Column Labels for each field  

5. In Options section, select ‘Row Seed Selection’.

   a. Row Seed Selection – set to ‘ALL’ to include all rows
   
   b. Row Seed Cells – add each significant field parameter (ex. $MyCpu)  -- must use ‘$’ as a prefix to indicate the Name of the field assigned in Step 3. 

6.	Go to Advanced tab of the sampler as shown below 

   a. Set File Trigger to the SAME filename used in Text Adapter section 



### NOTE: Please see sampler XML configuration for more details.