module Unityapi
  class UnityClient
    require 'savon'
  
    attr_accessor :client, :security_token, :user, :pass, :app
    def initialize(user, pass, app, path_to_wsdl)
      @user = user
      @pass = pass
      @app = app
      Savon.configure do |config|
        config.env_namespace = :soap
        config.log = false
        config.pretty_print_xml = true
      end
      @client = Savon.client(path_to_wsdl)
      @security_token = get_security_token(user, pass)
    end
  
    def close
      response = self.client.request("RetireSecurityToken", xmlns: "http://www.allscripts.com/Unity") do
        http.headers = {"Accept-Encoding" => "gzip, deflate", "SOAPAction" => "http://www.allscripts.com/Unity/IUnityService/RetireSecurityToken", "Content-Type" =>  "text/xml; charset=UTF-8"}
        soap.body = {"Token" => self.security_token, "Appname" => self.app}
      end    
    end
  
    def get_security_token(user, pass)
      response = self.client.request("GetSecurityToken", xmlns: "http://www.allscripts.com/Unity") do
        http.headers = {"Accept-Encoding" => "gzip, deflate", "SOAPAction" => "http://www.allscripts.com/Unity/IUnityService/GetSecurityToken", "Content-Type" =>  "text/xml; charset=UTF-8"}
        soap.body = {"Username" => user, "Password" => pass}
      end
      return response.body[:get_security_token_response][:get_security_token_result]
    end
  
    def magic_action(action, token, user_id="", patient_id = "", param_1=nil, param_2=nil, param_3=nil, param_4=nil, param_5=nil, param_6=nil)
      begin
        response = self.client.request("Magic", xmlns: "http://www.allscripts.com/Unity") do
          http.headers = {"Accept-Encoding" => "gzip, deflate", "SOAPAction" => "http://www.allscripts.com/Unity/IUnityService/Magic", "Content-Type" =>  "text/xml; charset=UTF-8"}
          soap.body = {
            "Action" => action,
            "Appname" => self.app,
            "UserID" => user_id,
            "PatientID" => patient_id,
            "Token" => token,
            "Parameter1" => param_1,
            "Parameter2" => param_2,
            "Parameter3" => param_3,
            "Parameter4" => param_4,
            "Parameter5" => param_5,
            "Parameter6" => param_6,
            "data" => nil,
            :attributes! => {"data" =>{"xsi:nil" => true}}
          }
        end
      rescue Timeout::Error
        puts "Timeout was rescued"
        30.times do |i|
          sleep 1
          puts "#{30 - i} seconds to next retry"
        end
        puts "retrying"
        retry
      end
      return response
    end

    def commit_charges(encounter_id, side_de)
    end
  
    def echo(patient_id="", param_1=nil, param_2=nil, param_3=nil, param_4=nil, param_5=nil, param_6=nil)
      response = magic_action("Echo", self.security_token, self.user, patient_id, param_1, param_2, param_3, param_4, param_5, param_6)
      return response.body[:magic_response][:magic_result][:diffgram][:echoresponse][:echoinformation]
    end
  
    def get_account
    end
  
    def get_changed_patients
    end
  
    def get_charge_info_by_username
    end
  
    def get_charges
    end
  
    def get_delegates
    end
  
    def get_dictionary
    end
  
    def get_dictionary_sets
    end
  
    def get_doc_template
    end
  
    def get_document_by_accession
    end
  
    def get_document_image
    end
  
    def get_documents
    end
  
    def get_document_type
    end
  
    def get_dur
    end
  
    def get_encounter
    end
  
    def get_encounter_date
    end
  
    def get_encounter_list
    end
  
    def get_hie_document
    end
  
    def get_last_patient
    end
  
    def get_list_of_dictionaries
    end
  
    def get_order_history
    end
  
    def get_organization_id
    end
  
    def get_packages
    end
  
    def get_patient
    end
  
    def get_patient_cda
    end
  
    def get_patient_diagnosis
    end
  
    def get_patient_full
    end
  
    def get_patient_ids
    end
  
    def get_patient_list
    end
  
    def get_patient_locations
    end
  
    def get_patient_problems
    end
  
    def get_patients_by_icd9
    end
  
    def get_patient_sections
    end
  
    def get_provider    
    end
  
    def get_providers
    end
  end
end