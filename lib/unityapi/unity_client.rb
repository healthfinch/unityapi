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
      return response.body[:magic_response][:magic_result][:diffgram][:getdoctemplateresponse][:getdoctemplateinfo]
    end
      
    def get_document_by_accession
      response = magic_action("GetDocumentByAccession", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getdocumentbyaccensionresponse][:getdocumentbyaccensioninfo]
    end
      
    def get_document_image
      response = magic_action("GetDocumentImage", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getdocumentimageresponse][:getdocumentimageinfo]
    end
      
    def get_documents
      response = magic_action("GetDocuments", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getdocumentsresponse][:getdocumentsinfo]
    end
      
    def get_document_type
      response = magic_action("GetDocumentType", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getdocumenttyperesponse][:getdocumenttypeinfo]
    end
      
    def get_dur
      response = magic_action("GetDUR", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getdurresponse][:getdurinfo]
    end
      
    def get_encounter
      response = magic_action("GetEncounter", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getencounterresponse][:getencounterinfo]
    end
      
    def get_encounter_date
      response = magic_action("GetEncounterDate", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getencounterdateresponse][:getencounterdateinfo]
    end
      
    def get_encounter_list
      response = magic_action("GetEncounterList", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getencounterlistresponse][:getencounterlistinfo]
    end
      
    def get_hie_document
      response = magic_action("GetHIEDocument", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:gethiedocumentresponse][:gethiedocumentinfo]
    end
      
    def get_last_patient
      response = magic_action("GetLastPatient", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getlastpatientresponse][:getlastpatientinfo]
    end
      
    def get_list_of_dictionaries
      response = magic_action("GetListOfDictionaries", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getlistofdictionariesresponse][:getlistofdictionariesinfo]
    end
      
    def get_order_history
      response = magic_action("GetOrderHistory", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getorderhistoryresponse][:getorderhistoryinfo]
    end
      
    def get_organization_id
      response = magic_action("GetOrganizationID", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getorganizationidresponse][:getorganizationidinfo]
    end
      
    def get_packages
      response = magic_action("GetPackages", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getpackagesresponse][:getpackagesinfo]
    end
      
    def get_patient
      response = magic_action("GetPatient", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientresponse][:getpatientinfo]
    end
    def get_patient_by_mrn
      response = magic_action("GetPatientByMRN", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientbymrnresponse][:getpatientbymrninfo]
    end
    def get_patient_cda
      response = magic_action("GetPatientCDA", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientcdaresponse][:getpatientcdainfo]
    end
      
    def get_patient_diagnosis
      response = magic_action("GetPatientDiagnosis", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientdiagnosisresponse][:getpatientdiagnosisinfo]
    end
      
    def get_patient_full
      response = magic_action("GetPatientFull", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientfullresponse][:getpatientfullinfo]
    end
      
    def get_patient_ids
      response = magic_action("GetPatientIDs", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientidsresponse][:getpatientidsinfo]
    end
      
    def get_patient_list
      response = magic_action("GetPatientList", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientlistresponse][:getpatientlistinfo]
    end
      
    def get_patient_locations
      response = magic_action("GetPatientLocations", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientlocationsresponse][:getpatientlocationsinfo]
    end
    def get_patient_pharmacies
      response = magic_action("GetPatientPharmacies", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientpharmaciesresponse][:getpatientpharmaciesinfo]
    end
      
    def get_patient_problems
      response = magic_action("GetPatientProblems", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientproblemsresponse][:getpatientproblemsinfo]
    end
      
    def get_patients_by_icd9
      response = magic_action("GetPatientsByICD9", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientsbyicd9response][:getpatientsbyicd9info]
    end
      
    def get_patient_sections
      response = magic_action("GetPatientSections", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientsectionsresponse][:getpatientsectionsinfo]
    end
      
    def get_provider
      response = magic_action("GetProvider", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getproviderresponse][:getproviderinfo]
    end
      
    def get_providers
      response = magic_action("GetProviders", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getprovidersresponse][:getprovidersinfo]
    end
    def get_ref_providers_by_specialty
      response = magic_action("GetRefProvidersBySpecialty", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getrefprovidersbyspecialtyresponse][:getrefprovidersbyspecialtyinfo]
    end
    def get_rounding_list_entries
      response = magic_action("GetRoundingListEntries", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getroundinglistentriesresponse][:getroundinglistentriesinfo]
    end
    def get_rounding_lists
      response = magic_action("GetRoundingLists", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getroundinglistsresponse][:getroundinglistsinfo]
    end
    def get_rx_favs
      response = magic_action("GetRXFavs", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getrxfavsresponse][:getrxfavsinfo]
    end
    def get_schedule
      response = magic_action("GetSchedule", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:scheduleresponse][:scheduleinfo]
    end
    def get_server_info
      response = magic_action("GetServerInfo", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getserverinforesponse][:getserverinfoinfo]
    end
    def get_sigs
      response = magic_action("GetSigs", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getsigsresponse][:getsigsinfo]
    end
    def get_site_config
      response = magic_action("GetSiteConfig", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getsiteconfigresponse][:getsiteconfiginfo]
    end
    def get_task
      response = magic_action("GetTask", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:gettaskresponse][:gettaskinfo]
    end
    def get_task_list
      response = magic_action("GetTaskList", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:gettasklistresponse][:gettasklistinfo]
    end
    def get_token_validation
      response = magic_action("GetTokenValidation", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:gettokenvalidationresponse][:gettokenvalidationinfo]
    end
    def get_user_authentication
      response = magic_action("GetUserAuthentication", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getuserauthenticationresponse][:getuserauthenticationinfo]
    end
    def get_user_id
      response = magic_action("GetUserID", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getuseridresponse][:getuseridinfo]
    end
    def get_user_security
      response = magic_action("GetUserSecurity", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getusersecurityresponse][:getusersecurityinfo]
    end
    def get_vaccine_manufacturers
      response = magic_action("GetVaccineManufacturers", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getvaccinemanufacturersresponse][:getvaccinemanufacturersinfo]
    end
    def get_vitals
      response = magic_action("GetVitals", self.security_token, self.user, self.app)
      return response.body[:magic_response][:magic_result][:diffgram][:getvitalsresponse][:getvitalsinfo]
    end
    
    def make_task(task_type, target_user, work_object_id)
      response = magic_action("MakeTask", self.security_token, self.user, self.app, task_type, target_user, work_object_id)
      return response.body[:magic_response][:magic_result][:diffgram][:maketaskresponse][:maketaskinfo]
    end
    
    def save_admin_task
    response = magic_action("SaveAdminTask", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:saveadmintaskresponse][:saveadmintaskinfo]
    end

    def save_allergy
    response = magic_action("SaveAllergy", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:saveallergyresponse][:saveallergyinfo]
    end

    def save_ced
    response = magic_action("SaveCED", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savecedresponse][:savecedinfo]
    end

    def save_charge
    response = magic_action("SaveCharge", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savechargeresponse][:savechargeinfo]
    end

    def save_chart_view_audit
    response = magic_action("SaveChartViewAudit", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savechartviewauditresponse][:savechartviewauditinfo]
    end

    def save_diagnosis
    response = magic_action("SaveDiagnosis", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savediagnosisresponse][:savediagnosisinfo]
    end

    def save_document_image
    response = magic_action("SaveDocumentImage", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savedocumentimageresponse][:savedocumentimageinfo]
    end

    def save_er_note
    response = magic_action("SaveERNote", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:saveernoteresponse][:saveernoteinfo]
    end

    def save_hie_document
    response = magic_action("SaveHIEDocument", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savehiedocumentresponse][:savehiedocumentinfo]
    end

    def save_history
    response = magic_action("SaveHistory", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savehistoryresponse][:savehistoryinfo]
    end

    def save_immunization
    response = magic_action("SaveImmunization", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:saveimmunizationresponse][:saveimmunizationinfo]
    end

    def save_note
    response = magic_action("SaveNote", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savenoteresponse][:savenoteinfo]
    end

    def save_patient
    response = magic_action("SavePatient", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savepatientresponse][:savepatientinfo]
    end

    def save_patientLocation
    response = magic_action("SavePatientLocation", self.security_token, self.user, self.app	 )
    return response.body[:magic_response][:magic_result][:diffgram][:savepatientlocationresponse][:savepatientlocationinfo]
    end

    def save_problem
    response = magic_action("SaveProblem", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:saveproblemresponse][:saveprobleminfo]
    end

    def save_problems_data
    response = magic_action("SaveProblemsData", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:saveproblemsdataresponse][:saveproblemsdatainfo]
    end

    def save_ref_provider
    response = magic_action("SaveRefProvider", self.security_token, self.user, self.app	 )
    return response.body[:magic_response][:magic_result][:diffgram][:saverefproviderresponse][:saverefproviderinfo]
    end

    def save_result
    response = magic_action("SaveResult", self.security_token, self.user, self.app	 )
    return response.body[:magic_response][:magic_result][:diffgram][:saveresultresponse][:saveresultinfo]
    end

    def save_rx
    response = magic_action("SaveRX", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:saverxresponse][:saverxinfo]
    end

    def save_simple_encounter
    response = magic_action("SaveSimpleEncounter", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savesimpleencounterresponse][:savesimpleencounterinfo]
    end

    def save_simple_rx
    response = magic_action("SaveSimpleRX", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savesimplerxresponse][:savesimplerxinfo]
    end

    def save_specialist
    response = magic_action("SaveSpecialist", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savespecialistresponse][:savespecialistinfo]
    end

    def save_task
    response = magic_action("SaveTask", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savetaskresponse][:savetaskinfo]
    end

    def save_task_status
    response = magic_action("SaveTaskStatus", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savetaskstatusresponse][:savetaskstatusinfo]
    end

    def save_unstructured_document
    response = magic_action("SaveUnstructuredDocument", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:saveunstructureddocumentresponse][:saveunstructureddocumentinfo]
    end

    def save_v10_doc_signature
    response = magic_action("SaveV10DocSignature", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savev10docsignatureresponse][:saveV10docsignatureinfo]
    end

    def save_v11_note
    response = magic_action("SaveV11Note", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savev11noteresponse][:savev11noteinfo]
    end

    def save_vitals
    response = magic_action("SaveVitals", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:savevitalsresponse][:savevitalsinfo]
    end

    def search_charge_codes
    response = magic_action("SearchChargeCodes", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:searchchargecodesresponse][:searchchargecodesinfo]
    end

    def search_diagnosis_codes
    response = magic_action("SearchDiagnosisCodes", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:searchdiagnosiscodesresponse][:searchdiagnosiscodesinfo]
    end

    def search_meds
    response = magic_action("SearchMeds", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:searchmedsresponse][:searchmedsinfo]
    end

    def search_patients
    response = magic_action("SearchPatients", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:searchpatientsresponse][:searchpatientsinfo]
    end

    def search_patients_rxhub5
    response = magic_action("SearchPatientsRXHub5", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:searchpatientsrxhub5response][:searchpatientsrxhub5info]
    end

    def search_pharmacies
    response = magic_action("SearchPharmacies", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:searchpharmaciesresponse][:searchpharmaciesinfo]
    end

    def search_problem_codes
    response = magic_action("SearchProblemCodes", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:searchproblemcodesresponse][:searchproblemcodesinfo]
    end

    def update_encounter
    response = magic_action("UpdateEncounter", self.security_token, self.user, self.app)
    return response.body[:magic_response][:magic_result][:diffgram][:updateencounterresponse][:updateencounterinfo]
    end

    def update_referral_order_status
    response = magic_action("UpdateReferralOrderStatus", self.security_token, self.user, self.app	 )
    return response.body[:magic_response][:magic_result][:diffgram][:updatereferralorderstatusresponse][:updatereferralorderstatusinfo]
    end
    
  end
end