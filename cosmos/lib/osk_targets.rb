###############################################################################
# OSK Targets
#
# Notes:
#   1. Most OSK target infrastructure (screens, libs, etc) is managed in the
#      typical COSMOS manner. Some artifcats are based on the apps that are
#      loaded during OSK intialization. This file defines functions that 
#      create those target artifacts.  
#
# License:
#   Written by David McComas, licensed under the copyleft GNU General Public
#   License (GPL).
#
###############################################################################

require 'cosmos'

module Osk


def self.create_json_table_mgmt_scr(app_list)

   t = Time.new 
   time_stamp = "_#{t.year}_#{t.month}_#{t.day}_#{t.hour}#{t.min}#{t.sec}"

   space_label = "          "
   
   scr_part1 = "
   ###############################################################################
   # JSON Table Management Screen
   #
   # Notes:
   #   1. Do not edit this file because it is automatically generated by and your
   #      changes will not be saved.
   #   2. File created by osk_targets.rb on #{time_stamp}
   #
   # License:
   #   Written by David McComas, licensed under the copyleft GNU General Public
   #   License (GPL).
   #
   ###############################################################################

   SCREEN AUTO AUTO 0.5
   GLOBAL_SETTING BUTTON BACKCOLOR 221 221 221

   TITLE \"JSON Table Management\"
     SETTING BACKCOLOR 162 181 205
     SETTING TEXTCOLOR black

     HORIZONTALBOX\n"
     
   # app_tbl_combo - Created below 
   
   scr_part2 = "
       BUTTON 'Load'    'require \"#{Cosmos::USERPATH}/config/targets/CFS_KIT/lib/json_table_mgmt_screen.rb\"; json_table_mgmt(self, \"LOAD\")'
       BUTTON 'Dump'    'require \"#{Cosmos::USERPATH}/config/targets/CFS_KIT/lib/json_table_mgmt_screen.rb\"; json_table_mgmt(self, \"DUMP\")'
       BUTTON 'Display' 'require \"#{Cosmos::USERPATH}/config/targets/CFS_KIT/lib/json_table_mgmt_screen.rb\"; json_table_mgmt(self, \"DISPLAY\")'
     END

   HORIZONTALLINE
     
     SCROLLWINDOW
     MATRIXBYCOLUMNS 6 10 10
     
       LABEL \"#{space_label}\"
       LABEL \"#{space_label}\"
       LABEL \"Application\"
       LABEL \"Cmd Valid Cnt\"
       LABEL \"Cmd Error Cnt\"
       LABEL \"#{space_label}\"\n\n"
  
   # hk_label_matrix - Created below 
   
   scr_part3 = "
     END # Matrix
     END # Scroll Window

   HORIZONTALLINE
     
   VERTICALBOX \"File Transfer\"
     MATRIXBYCOLUMNS 2
       # Use table_mgmt because table file needs to be manipulated after transferred
       BUTTON 'Put File' 'require \"#{Cosmos::USERPATH}/config/targets/CFS_KIT/lib/table_mgmt_screen.rb\"; table_mgmt_send_cmd(self, \"PUT_FILE\")'
       BUTTON 'Get File' 'require \"#{Cosmos::USERPATH}/config/targets/CFS_KIT/lib/table_mgmt_screen.rb\"; table_mgmt_send_cmd(self, \"GET_FILE\")'
       LABELVALUE TFTP HK_TLM_PKT PUT_FILE_COUNT
       LABELVALUE TFTP HK_TLM_PKT GET_FILE_COUNT
     END # Matrix
     LABEL 'Ground Working Directory'
           SETTING HEIGHT 20
     NAMED_WIDGET gnd_work_dir TEXTFIELD 256
           #SETTING WIDTH 100
           SETTING HEIGHT 20
     LABEL 'Flight Working Directory'
           SETTING HEIGHT 20
     NAMED_WIDGET flt_work_dir TEXTFIELD 256
           #SETTING WIDTH 100
           SETTING HEIGHT 20
   END # Vertical File Transfer
   HORIZONTALLINE
   LABEL \"Flight Event Messages\"
   NAMED_WIDGET evs_msg_t TEXTBOX CFE_EVS EVENT_MSG_PKT MESSAGE 600 50\n"
   
   scr_file = "#{Osk::SCR_DIR}/#{Osk::JSON_TBL_MGMT_SCR_FILE}"
   #puts scr_file
   
   begin
            
      # Always overwrite the file      
      File.open("#{scr_file}","w") do |f| 
        

         app_tbl_combo = "       NAMED_WIDGET app COMBOBOX "
         hk_label_matrix = ""
         
         app_list.each do |key, app|

            if (not app.app_framework.nil?)
               if (app.app_framework == "osk")
               
                  hk_label_matrix << "       LABEL \"#{space_label}\"\n"
                  hk_label_matrix << "       LABEL \"#{space_label}\"\n"
                  hk_label_matrix << "       LABEL \"  #{app.fsw_name}\"\n"
                  hk_label_matrix << "       VALUE #{app.fsw_name} HK_TLM_PKT CMD_VALID_COUNT\n"
                  hk_label_matrix << "       VALUE #{app.fsw_name} HK_TLM_PKT CMD_ERROR_COUNT\n"
                  hk_label_matrix << "       LABEL \"#{space_label}\"\n\n"
                  
                  app.tables.each do |tbl|
                     app_tbl_combo << "#{app.fsw_name}-#{tbl.id}-#{tbl.name} " 
                  end

               end # If app uses OSK framework
            end # If framework type defined
            
         end # app_list loop
                  
         f.write (scr_part1)
         f.write (app_tbl_combo)
         f.write (scr_part2)
         f.write (hk_label_matrix)
         f.write (scr_part3)

      end # File
      
   rescue Exception => e
      puts e.message
      puts e.backtrace.inspect  
   end

end # create_json_table_mgmt_scr()
   
end # Module Osk