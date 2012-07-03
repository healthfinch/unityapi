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
    
    # def method_missing(name, *args, &block)
    #   if name.to_s =~ /^get_(.+)$/
    #     run_get_methods($1, *args, &block)
    #   else
    #     super
    #   end
    # end
    # 
    # def respond_to?(meth)
    #   if meth.to_s =~ /^get_(.+)$/
    #     true
    #   else
    #     super
    #   end
    # end
    # 
    # # def run_get_methods(attrs, *args, &block)  
    # #   cameled = attrs.to_s.sub(/^[a-z\d]*/) { inflections.acronyms[$&] || $&.capitalize }
    # #   cameled.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{inflections.acronyms[$2] || $2.capitalize}" }.gsub('/', '::')
    # #   
    # #   symname = attrs.clone.delete("_")
    # #   puts "running method missing for Get#{attrs.camelize} with symname #{symname}"
    # #   response = magic_action("Get#{attrs.camelize}", self.security_token, self.user, self.app, *args)
    # #   return response.body[:magic_response][:magic_result][:diffgram]["#{symname}response".to_sym]["#{symname}info".to_sym]
    # # end

    def commit_charges(encounter_id, side_de)
    end
  
    def echo(patient_id="", param_1=nil, param_2=nil, param_3=nil, param_4=nil, param_5=nil, param_6=nil)
      response = magic_action("Echo", self.security_token, self.user, patient_id, param_1, param_2, param_3, param_4, param_5, param_6)
      return response.body[:magic_response][:magic_result][:diffgram][:echoresponse][:echoinformation]
    end
  
    def get_account
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getaccountresponse][:getaccountinfo]
    end
      
    def get_changed_patients(start_time)
      response = magic_action("GetChangedPatients", self.security_token, self.user, self.app, start_time)
      return response.body[:magic_response][:magic_result][:diffgram][:getchangedpatientsresponse][:getchangedpatientsinfo].map(&:patientid)
    end
      
    def get_charge_info_by_username
      response = magic_action("GetChargeInfoByUsername", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getchargeinfobyusernameresponse][:getchargeinfobyusernameinfo]
    end
      
    def get_charges
      response = magic_action("GetCharges", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getchargesresponse][:getchargesinfo]
    end
      
    def get_delegates
      response = magic_action("GetDelegates", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getdelegatesresponse][:getdelegatesinfo]
    end
      
    def get_dictionary
      response = magic_action("GetDictionary", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getdictionaryresponse][:getdictionaryinfo]
    end
      
    def get_dictionary_sets
      response = magic_action("GetDictionarySets", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getdictionarysetsresponse][:getdictionarysetsinfo]
    end
      
    def get_doc_template
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getdoctemplateresponse]
    end
      
    def get_document_by_accession
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getdocumentbyaccension]
    end
      
    def get_document_image
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_documents
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_document_type
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_dur
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_encounter
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_encounter_date
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_encounter_list
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_hie_document
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_last_patient
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_list_of_dictionaries
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_order_history
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_organization_id
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_packages
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_patient
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_patient_cda
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_patient_diagnosis
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_patient_full
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_patient_ids
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_patient_list
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_patient_locations
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_patient_problems
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_patients_by_icd9
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_patient_sections
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_provider
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
      
    def get_providers
      response = magic_action("GetAccount", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram]
    end
  end
end