###############################################################################
# cFS Kit Create App Screen
#
# Notes:
#   None 
#
# License:
#   Written by David McComas, licensed under the copyleft GNU General 
#   Public License (GPL).
# 
################################################################################

require 'fileutils'
require 'json'

require 'osk_global'
require 'app_template'



JSON_CONFIG_FILE = File.join(Osk::TOOLS_DIR,'create-app',Osk::CREATE_APP_JSON_FILE)

# JSON config file labels 
JSON_VERSION          = "version"
JSON_DIR              = "dir"
JSON_DIR_SRC_TEMPLATE = "src-template"
JSON_DIR_DST_CFS      = "dst-cfs"
JSON_DIR_DST_COSMOS   = "dst-cosmos"
JSON_TEMPLATE_VAR     = "template-var"

$template_dir = {}

def create_app_set_template_dir(template_dir)

   #puts "create_app_set_template_dir(#{template_dir})\n"
   $template_dir = template_dir

end

def create_app_display_template_info(screen)
 
   template_sel = screen.get_named_widget("template").text

   template_info = AppTemplate.get_descr($template_dir[template_sel])

   create_app_create_template_info_screen(template_sel, template_info)

   display("CFS_KIT #{File.basename(Osk::TEMPLATE_INFO_SCR_FILE,'.txt')}",50,50)

end # create_app_display_template_info()

def continue_button(screen, cfs_target_dir, cosmos_target_dir)
   app_name_widget = screen.get_named_widget("app_name_widget")
   sub_template = "Dan Templates Wrapper"
   app_name = app_name_widget.text #TODO: truncate in max 9 characters
   periodicity = screen.get_named_widget("periodicity")
   has_table = screen.get_named_widget("has_table")
   has_cds = screen.get_named_widget("has_cds")
   
   if periodicity.text == "Time-Out Periodic" and has_table.text == "Yes" and has_cds.text == "Yes"
      #Type 1: Time-Out Periodic with CDS storage with tables
      sub_template = "subtemplate1"
   elsif periodicity.text == "Time-Out Periodic" and has_table.text == "No" and has_cds.text == "Yes"
      #Type 2: Time-Out Periodic with CDS storage without tables
      sub_template = "subtemplate2"
   elsif periodicity.text == "Time-Out Periodic" and has_table.text == "Yes" and has_cds.text == "No"
      #Type 3: Time-Out Periodic without CDS storage with tables
      sub_template = "subtemplate3"
   elsif periodicity.text == "Time-Out Periodic" and has_table.text == "No" and has_cds.text == "No"
      #Type 4: Time-Out Periodic without CDS storage without tables
      sub_template = "subtemplate4"
   elsif periodicity.text == "Soft Periodic" and has_table.text == "Yes" and has_cds.text == "Yes"
      #Type 5: Soft-Critical Periodic with CDS storage with tables
      sub_template = "subtemplate5"
   elsif periodicity.text == "Soft Periodic" and has_table.text == "No" and has_cds.text == "Yes"
      #Type 6: Soft-Critical Periodic with CDS storage without tables
      sub_template = "subtemplate6"
   elsif periodicity.text == "Soft Periodic" and has_table.text == "Yes" and has_cds.text == "No"
      #Type 7: Soft-Critical Periodic without CDS storage with tables
      sub_template = "subtemplate7"
   elsif periodicity.text == "Soft Periodic" and has_table.text == "No" and has_cds.text == "No"
      #Type 8: Soft-Critical Periodic without CDS storage without tables
      sub_template = "subtemplate8"
   elsif periodicity.text == "Asynchronous" and has_table.text == "Yes" and has_cds.text == "Yes"
      #Type 9: Asynchronous with CDS storage with tables
      sub_template = "subtemplate9"
   elsif periodicity.text == "Asynchronous" and has_table.text == "No" and has_cds.text == "Yes"
      #Type 10: Asynchronous with CDS storage without tables
      sub_template = "subtemplate10"
   elsif periodicity.text == "Asynchronous" and has_table.text == "Yes" and has_cds.text == "No"
      #Type 11: Asynchronous without CDS storage with tables
      sub_template = "subtemplate11"
   elsif periodicity.text == "Asynchronous" and has_table.text == "No" and has_cds.text == "No"
      #Type 12: Asynchronous without CDS storage without tables
      sub_template = "subtemplate12"
   end

   params = {"app_name": app_name,
            "periodicity": periodicity,
            "cfs_target_dir": cfs_target_dir,
            "sub_template": sub_template,
            "cosmos_target_dir": cosmos_target_dir}

   create_app_execute2(params)
end

def create_app_execute(screen)

   @template_sel = screen.get_named_widget("template")
   @cfs_target_dir    = screen.get_named_widget("cfs_target_dir")
   @cosmos_target_dir = screen.get_named_widget("cosmos_target_dir")
   
   if @template_sel.text == "Dan Templates Wrapper"

      screen_def = '
         SCREEN AUTO AUTO 0.5 FIXED
         VERTICAL
            MATRIXBYCOLUMNS 2
              LABEL "Enter app name"
              NAMED_WIDGET app_name_widget TEXTFIELD 256 "example_app"
            END            
            MATRIXBYCOLUMNS 2
               LABEL "Periodicity"
               NAMED_WIDGET periodicity COMBOBOX "Time-Out Periodic" "Soft Periodic" "Asynchronous"
            END
            MATRIXBYCOLUMNS 2
               LABEL "cFS Tables needed?"
               NAMED_WIDGET has_table COMBOBOX "Yes" "No"
            END
            MATRIXBYCOLUMNS 2
               LABEL "cFS Critical Data Storage?"
               NAMED_WIDGET has_cds COMBOBOX "Yes" "No"
            END
            MATRIXBYCOLUMNS 2
               LABEL "Create App"
               BUTTON "OK" "continue_button(self, @cfs_target_dir, @cosmos_target_dir)"
            END
         END 
         '
         screen = local_screen("Dan Templates Wrapper", screen_def, 200, 200)
   else
      # COSMOS seems to enforce some input, but verify return just in case
      @app_name = ask_string("Enter app/lib name")
      return unless (!@app_name.nil? or @app_name != "")
      create_app_execute2
   end   
end

#
# Create an application/library based on the user template selection
#
def create_app_execute2(*params)  
   
   config = read_config_file(JSON_CONFIG_FILE)
   dirs = get_default_dirs(config)   

   app_name = @app_name.nil? ? params[0][:app_name] : @app_name
   #template_text = @template_sel.nil? ? "Dan Template" : @template_sel.text
   template_text = @template_sel.nil? ? params[0][:sub_template] : @template_sel.text
   cfs_target_dir_text = (@cfs_target_dir.nil? || @cfs_target_dir.text.nil?) ? dirs["CFS"] : (@cfs_target_dir.text.empty? ? dirs["CFS"] : @cfs_target_dir.text)
   cosmos_target_dir_text = (@cosmos_target_dir.nil? || @cosmos_target_dir.text.nil? || @cosmos_target_dir.text == "") ? dirs["COSMOS"] : (@cosmos_target_dir.text.empty? ? dirs["COSMOS"] : @cosmos_target_dir.text)

   begin

      app_template = AppTemplate.new(app_name, config[JSON_TEMPLATE_VAR])
      
      status = app_template.create_app($template_dir[template_text], cfs_target_dir_text, cosmos_target_dir_text)

      if status 
          if app_template.include_cosmos
             app_template.update_cosmos_cmd_tlm_server
          end
          prompt "Sucessfully created #{app_name} in\n   cFS directory #{cfs_target_dir_text}\n   COSMOS directory #{cosmos_target_dir_text}"
      else
          prompt "Error creating #{app_name}"
      end
   
   rescue Exception => e

      prompt e.message
      #puts e.backtrace.inpsect
	   
   end

     
end # create_app_execute()

def create_app_manage_dir(screen, cmd)
 

   begin
 
      if cmd.include? "SHOW_DEFAULT"

         config = read_config_file(JSON_CONFIG_FILE)  
         dirs   = get_default_dirs(config)

         if cmd.include? "CFS"
            cfs_target_dir = screen.get_named_widget("cfs_target_dir")
            cfs_target_dir.text = dirs['CFS']
         else
            cosmos_target_dir = screen.get_named_widget("cosmos_target_dir")
            cosmos_target_dir.text = dirs['COSMOS']
         end

      elsif (cmd == "BROWSE_CFS")
   
         path_filename = open_directory_dialog(File.join(Osk::OSK_CFS_DIR,'apps'))
         if (path_filename != "" and !path_filename.nil?)
            cfs_target_dir = screen.get_named_widget("cfs_target_dir")
            cfs_target_dir.text = path_filename
         end

      elsif (cmd == "BROWSE_COSMOS")
   
         path_filename = open_directory_dialog(File.join(Cosmos::USERPATH,'config','targets'))
         if (path_filename != "" and !path_filename.nil?)
            cosmos_target_dir = screen.get_named_widget("cosmos_target_dir")
            cosmos_target_dir.text = path_filename
         end
      elsif (cmd == "TODO")
         prompt("Feature coming soon...")
      else
         raise "Error in screen definition file. Undefined command sent to create_app_manage_dir()"
      end

   rescue Exception => e

      prompt("Exception in create_app_manage_directories()\n#{e.message}\n #{e.backtrace.inpsect}")
	   
   end
     
end # create_app_manage_directories()

#
# Get the default directories from the JSON configuration file. All of the 
# directories should be defined in the config file so the config definitions
# are verified regardles of whether the user needs it.
#
def get_default_dirs(config)

   dir_config = config[JSON_DIR]

   template_dir   = File.join(Osk::TOOLS_DIR,'create-app',dir_config[JSON_DIR_SRC_TEMPLATE])
   cfs_dst_dir    = File.join(Osk::OSK_CFS_DIR,dir_config[JSON_DIR_DST_CFS])
   cosmos_dst_dir = File.join(Cosmos::USERPATH,dir_config[JSON_DIR_DST_COSMOS])
         
   raise IOError "Configuration file #{JSON_CONFIG_FILE} relative template directory resolved to a non-existant directory: #{template_dir}."  unless Dir.exist?(template_dir)
   raise IOError "Configuration file #{JSON_CONFIG_FILE} relative cFS directory resolved to a non-existant directory: #{cfs_dst_dir}."        unless Dir.exist?(cfs_dst_dir)
   raise IOError "Configuration file #{JSON_CONFIG_FILE} relative COSMOS directory resolved to a non-existant directory: #{cosmos_dst_dir}."  unless Dir.exist?(cosmos_dst_dir)
         
   return {'TEMPLATE' => template_dir, 'CFS' => cfs_dst_dir, 'COSMOS' => cosmos_dst_dir}

end # get_default_dirs()


#
# Read the JSON configuration file and verify the required fields
#
def read_config_file(config_file)

   raise IOError "Configuration file #{config_file} does not exist" unless File.exist?(config_file)
   config_json = File.read(config_file)
   config = JSON.parse(config_json)
      
   raise NameError "Configuration file #{config_file} missing #{JSON_TEMPLATE_VAR} definition"  unless config.key?(JSON_TEMPLATE_VAR)

   dir_config = config[JSON_DIR]

   raise NameError "Configuration file #{config_file} missing #{JSON_DIR} => #{JSON_DIR_SRC_TEMPLATE} definition"  unless dir_config.key?(JSON_DIR_SRC_TEMPLATE)
   raise NameError "Configuration file #{config_file} missing #{JSON_DIR} => #{JSON_DIR_DST_CFS} definition"       unless dir_config.key?(JSON_DIR_DST_CFS)
   raise NameError "Configuration file #{config_file} missing #{JSON_DIR} => #{JSON_DIR_DST_COSMOS} definition"    unless dir_config.key?(JSON_DIR_DST_COSMOS)

   return config
      
end # read_config_file()

################################################################################
## Create Template Info Screen
################################################################################


def create_app_create_template_info_screen(template_title, template_info)

   t = Time.new 
   time_stamp = "_#{t.year}_#{t.month}_#{t.day}_#{t.hour}#{t.min}#{t.sec}"

   template_info_scr_header = "
   ###############################################################################
   # cfs_kit Template Info Screen
   #
   # Notes:
   #   1. Do not edit this file because it is automatically generated and your
   #      changes will not be saved.
   #   2. File created by create_app_screen.rb on #{time_stamp}
   #
   # License:
   #   Written by David McComas, licensed under the copyleft GNU General Public
   #   License (GPL).
   #
   ###############################################################################

   SCREEN AUTO AUTO 0.5
   GLOBAL_SETTING BUTTON BACKCOLOR 221 221 221
  
   TITLE \"#{template_title}\"
   SETTING BACKCOLOR 162 181 205
   SETTING TEXTCOLOR black
      
   VERTICALBOX \"\" 10
   "

   template_info_scr_trailer = "
   END # Vertical Box
   "
   
   template_scr_file = File.join(Osk::SCR_DIR,Osk::TEMPLATE_INFO_SCR_FILE)

   begin
         
      # Always overwrite the temp file      
      File.open(template_scr_file,"w") do |f| 
           
         f.write (template_info_scr_header)

         f.write ("\n   LABEL \"  \"\n")
  
         info_line = 1
         info_line_str = ""
         template_info.each do |line|
            info_line_str << "   NAMED_WIDGET line_#{info_line} LABEL \"#{line}\"\n"         
            info_line_str << "   SETTING TEXTCOLOR 0 0 153\n"
            info_line += 1
         end
            
         f.write (info_line_str)
         f.write ("\n   LABEL \"  \"\n")
         f.write (template_info_scr_trailer)

      end # File
         
   rescue Exception => e
      puts e.message
      puts e.backtrace.inspect  
   end

end # create_app_create_template_info_screen()


