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
  
    def magic_action(action, patient_id = "", param_1=nil, param_2=nil, param_3=nil, param_4=nil, param_5=nil, param_6=nil)
      begin
        response = self.client.request("Magic", xmlns: "http://www.allscripts.com/Unity") do
          http.headers = {"Accept-Encoding" => "gzip, deflate", "SOAPAction" => "http://www.allscripts.com/Unity/IUnityService/Magic", "Content-Type" =>  "text/xml; charset=UTF-8"}
          soap.body = {
            "Action" => action,
            "Appname" => self.app,
            "UserID" => self.user,
            "PatientID" => patient_id,
            "Token" => self.security_token,
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
      response = magic_action("CommitCharges", patient_id, encounter_id, site_de)
      return response.body[:magic_response][:magic_result][:diffgram][:commitchargesresponse][:commitchargesinfo]
    end
  
    def echo(patient_id="", param_1=nil, param_2=nil, param_3=nil, param_4=nil, param_5=nil, param_6=nil)
      response = magic_action("Echo", patient_id, param_1, param_2, param_3, param_4, param_5, param_6)
      return response.body[:magic_response][:magic_result][:diffgram][:echoresponse][:echoinformation]
    end
  
    def get_account
      response = magic_action("GetAccount")
      return response.body[:magic_response][:magic_result][:diffgram][:getaccountresponse][:getaccountinfo]
    end
      
    def get_changed_patients(start_time=nil)
      response = magic_action("GetChangedPatients", nil, start_time)
      return response.body[:magic_response][:magic_result][:diffgram][:getchangedpatientsresponse][:getchangedpatientsinfo].map(&:patientid)
    end
      
    def get_charge_info_by_username(username_filter=nil)
      response = magic_action("GetChargeInfoByUsername", nil, username_filter)
      return response.body[:magic_response][:magic_result][:diffgram][:getchargeinfobyusernameresponse][:getchargeinfobyusernameinfo]
    end
      
    def get_charges(encounter_id=nil)
      response = magic_action("GetCharges", nil, encounter_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getchargesresponse][:getchargesinfo]
    end
      
    def get_delegates
      response = magic_action("GetDelegates")
      return response.body[:magic_response][:magic_result][:diffgram][:getdelegatesresponse][:getdelegatesinfo]
    end
      
    def get_dictionary(dictionary_name, site=nil)
      response = magic_action("GetDictionary", nil, dictionary_name, site)
      return response.body[:magic_response][:magic_result][:diffgram][:getdictionaryresponse][:getdictionaryinfo]
    end
      
    def get_dictionary_sets(group_name, dictionary_set_name)
      response = magic_action("GetDictionarySets", nil, group_name, dictionary_set_name)
      return response.body[:magic_response][:magic_result][:diffgram][:getdictionarysetsresponse][:getdictionarysetsinfo]
    end
      
    def get_doc_template(section, template)
      response = magic_action("GetAccount", nil, section, template)
      return response.body[:magic_response][:magic_result][:diffgram][:getdoctemplateresponse][:getdoctemplateinfo]
    end
      
    def get_document_by_accession(patient_id=nil, accession_num)
      response = magic_action("GetDocumentByAccession", patient_id, accession_num)
      return response.body[:magic_response][:magic_result][:diffgram][:getdocumentbyaccensionresponse][:getdocumentbyaccensioninfo]
    end
      
    def get_document_image(patient_id=nil, document_id)
      response = magic_action("GetDocumentImage", patient_id, document_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getdocumentimageresponse][:getdocumentimageinfo]
    end
      
    def get_documents(patient_id, document_id, document_type=nil, start_date=nil, end_date=nil)
      response = magic_action("GetDocuments", patient_id, start_date, end_date, document_id, document_type)
      return response.body[:magic_response][:magic_result][:diffgram][:getdocumentsresponse][:getdocumentsinfo]
    end
      
    def get_document_type(doc_type=nil)#could be "Chart", "Consult", "SpecReport", "ChartCopy" or nil
      response = magic_action("GetDocumentType", nil, doc_type)
      return response.body[:magic_response][:magic_result][:diffgram][:getdocumenttyperesponse][:getdocumenttypeinfo]
    end
      
    def get_dur(dur_type, client_id, rx_data)
      response = magic_action("GetDUR", nil, dur_type, client_id, rx_data)
      return response.body[:magic_response][:magic_result][:diffgram][:getdurresponse][:getdurinfo]
    end
      
    def get_encounter(patient_id, encounter_type, encounter_time, force_new_encounter, match_provider_flag)
      response = magic_action("GetEncounter", patient_id, encounter_type, encounter_time, force_new_encounter, match_provider_flag)
      return response.body[:magic_response][:magic_result][:diffgram][:getencounterresponse][:getencounterinfo]
    end
      
    def get_encounter_date(patient_id, encounter_id)
      response = magic_action("GetEncounterDate", patient_id, encounter_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getencounterdateresponse][:getencounterdateinfo]
    end
      
    def get_encounter_list(patient_id, encounter_type, date, future_days, show_previous_encounters, billing_provider)
      response = magic_action("GetEncounterList", patient_id, encounter_type, date, future_days, show_previous_encounters, billing_provider)
      return response.body[:magic_response][:magic_result][:diffgram][:getencounterlistresponse][:getencounterlistinfo]
    end
      
    def get_hie_document(patient_id)
      response = magic_action("GetHIEDocument", patient_id)
      return response.body[:magic_response][:magic_result][:diffgram][:gethiedocumentresponse][:gethiedocumentinfo]
    end
      
    def get_last_patient
      response = magic_action("GetLastPatient", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:getlastpatientresponse][:getlastpatientinfo]
    end
      
    def get_list_of_dictionaries
      response = magic_action("GetListOfDictionaries", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:getlistofdictionariesresponse][:getlistofdictionariesinfo]
    end
      
    def get_order_history(item_id)
      response = magic_action("GetOrderHistory", nil, item_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getorderhistoryresponse][:getorderhistoryinfo]
    end
      
    def get_organization_id
      response = magic_action("GetOrganizationID", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:getorganizationidresponse][:getorganizationidinfo]
    end
      
    def get_packages(org_name)
      response = magic_action("GetPackages", nil. org_name)
      return response.body[:magic_response][:magic_result][:diffgram][:getpackagesresponse][:getpackagesinfo]
    end
      
    def get_patient(patient_id, include_pic)
      response = magic_action("GetPatient", patient_id, include_pic)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientresponse][:getpatientinfo]
    end
    def get_patient_by_mrn(mrn)
      response = magic_action("GetPatientByMRN", nil, mrn)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientbymrnresponse][:getpatientbymrninfo]
    end
    def get_patient_cda(patient_id, organization_id=nil, appgroup=nil)
      response = magic_action("GetPatientCDA", patient_id, organization_id, appgroup)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientcdaresponse][:getpatientcdainfo]
    end
      
    def get_patient_diagnosis(patient_id, encounter_date, encounter_type_mnemonic, encounter_date_rage, encounter_id)
      response = magic_action("GetPatientDiagnosis", patient_id, encounter_date, encounter_type_mnemonic, encounter_date_rage, encounter_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientdiagnosisresponse][:getpatientdiagnosisinfo]
    end
      
    def get_patient_full(patient_id, mrn, org_id, order_id)
      response = magic_action("GetPatientFull", patient_id, mrn, org_id, order_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientfullresponse][:getpatientfullinfo]
    end
      
    def get_patient_ids(patient_id)
      response = magic_action("GetPatientIDs", patient_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientidsresponse][:getpatientidsinfo]
    end
      
    def get_patient_list(location_code, appt_date)
      response = magic_action("GetPatientList", nil, location_code, appt_date)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientlistresponse][:getpatientlistinfo]
    end
      
    def get_patient_locations(user_xml=nil) #user_xml needs to be better defined and broken down into true params
      response = magic_action("GetPatientLocations", nil, user_xml)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientlocationsresponse][:getpatientlocationsinfo]
    end
    def get_patient_pharmacies(patient_id)
      response = magic_action("GetPatientPharmacies", patient_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientpharmaciesresponse][:getpatientpharmaciesinfo]
    end
      
    def get_patient_problems(patient_id, show_by_encounter_flag=nil, assessed=nil, encounter_id=nil, medcin_id=nil)
      response = magic_action("GetPatientProblems", patient_id, show_by_encounter_flag, assessed, encounter_id, medcin_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientproblemsresponse][:getpatientproblemsinfo]
    end
      
    def get_patients_by_icd9(icd_9, start_date, end_date)
      response = magic_action("GetPatientsByICD9", nil, icd_9, start_date, end_date)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientsbyicd9response][:getpatientsbyicd9info]
    end
      
    def get_patient_sections(patient_id, months)
      response = magic_action("GetPatientSections", patient_id, months)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientsectionsresponse][:getpatientsectionsinfo]
    end
      
    def get_provider(provider_id, user_name)
      response = magic_action("GetProvider", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:getproviderresponse][:getproviderinfo]
    end
      
    def get_providers(security_filter=nil, name_filter=nil)
      response = magic_action("GetProviders", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:getprovidersresponse][:getprovidersinfo]
    end
    def get_ref_providers_by_specialty(search)
      response = magic_action("GetRefProvidersBySpecialty", nil, search)
      return response.body[:magic_response][:magic_result][:diffgram][:getrefprovidersbyspecialtyresponse][:getrefprovidersbyspecialtyinfo]
    end
    def get_rounding_list_entries(patient_list_id, sort_field, sort_order, org_id, timezone_offset)
      response = magic_action("GetRoundingListEntries", nil, patient_list_id, sort_field, sort_order, org_id, timezone_offset)
      return response.body[:magic_response][:magic_result][:diffgram][:getroundinglistentriesresponse][:getroundinglistentriesinfo]
    end
    def get_rounding_lists(org_id)
      response = magic_action("GetRoundingLists", nil, org_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getroundinglistsresponse][:getroundinglistsinfo]
    end
    def get_rx_favs
      response = magic_action("GetRXFavs", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:getrxfavsresponse][:getrxfavsinfo]
    end
    def get_schedule
      response = magic_action("GetSchedule", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:scheduleresponse][:scheduleinfo]
    end
    def get_server_info
      response = magic_action("GetServerInfo", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:getserverinforesponse][:getserverinfoinfo]
    end
    def get_sigs
      response = magic_action("GetSigs", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:getsigsresponse][:getsigsinfo]
    end
    def get_site_config
      response = magic_action("GetSiteConfig", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:getsiteconfigresponse][:getsiteconfiginfo]
    end
    def get_task
      response = magic_action("GetTask", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:gettaskresponse][:gettaskinfo]
    end
    def get_task_list
      response = magic_action("GetTaskList", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:gettasklistresponse][:gettasklistinfo]
    end
    def get_token_validation
      response = magic_action("GetTokenValidation", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:gettokenvalidationresponse][:gettokenvalidationinfo]
    end
    def get_user_authentication
      response = magic_action("GetUserAuthentication", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:getuserauthenticationresponse][:getuserauthenticationinfo]
    end
    def get_user_id
      response = magic_action("GetUserID", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:getuseridresponse][:getuseridinfo]
    end
    def get_user_security
      response = magic_action("GetUserSecurity", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:getusersecurityresponse][:getusersecurityinfo]
    end
    def get_vaccine_manufacturers
      response = magic_action("GetVaccineManufacturers", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:getvaccinemanufacturersresponse][:getvaccinemanufacturersinfo]
    end
    def get_vitals
      response = magic_action("GetVitals", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:getvitalsresponse][:getvitalsinfo]
    end
    
    def make_task(task_type, target_user, work_object_id)
      response = magic_action("MakeTask", nil, task_type, target_user, work_object_id)
      return response.body[:magic_response][:magic_result][:diffgram][:maketaskresponse][:maketaskinfo]
    end
    
    def save_admin_task
      response = magic_action("SaveAdminTask", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:saveadmintaskresponse][:saveadmintaskinfo]
    end

    def save_allergy
      response = magic_action("SaveAllergy", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:saveallergyresponse][:saveallergyinfo]
    end

    def save_ced
      response = magic_action("SaveCED", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savecedresponse][:savecedinfo]
    end

    def save_charge
      response = magic_action("SaveCharge", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savechargeresponse][:savechargeinfo]
    end

    def save_chart_view_audit
      response = magic_action("SaveChartViewAudit", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savechartviewauditresponse][:savechartviewauditinfo]
    end

    def save_diagnosis
      response = magic_action("SaveDiagnosis", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savediagnosisresponse][:savediagnosisinfo]
    end

    def save_document_image
      response = magic_action("SaveDocumentImage", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savedocumentimageresponse][:savedocumentimageinfo]
    end

    def save_er_note
      response = magic_action("SaveERNote", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:saveernoteresponse][:saveernoteinfo]
    end

    def save_hie_document
      response = magic_action("SaveHIEDocument", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savehiedocumentresponse][:savehiedocumentinfo]
    end

    def save_history
      response = magic_action("SaveHistory", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savehistoryresponse][:savehistoryinfo]
    end

    def save_immunization
      response = magic_action("SaveImmunization", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:saveimmunizationresponse][:saveimmunizationinfo]
    end

    def save_note
      response = magic_action("SaveNote", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savenoteresponse][:savenoteinfo]
    end

    def save_patient
      response = magic_action("SavePatient", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savepatientresponse][:savepatientinfo]
    end

    def save_patient_location
      response = magic_action("SavePatientLocation", nil	 )
      return response.body[:magic_response][:magic_result][:diffgram][:savepatientlocationresponse][:savepatientlocationinfo]
    end

    def save_problem
      response = magic_action("SaveProblem", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:saveproblemresponse][:saveprobleminfo]
    end

    def save_problems_data
      response = magic_action("SaveProblemsData", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:saveproblemsdataresponse][:saveproblemsdatainfo]
    end

    def save_ref_provider
      response = magic_action("SaveRefProvider", nil	 )
      return response.body[:magic_response][:magic_result][:diffgram][:saverefproviderresponse][:saverefproviderinfo]
    end

    def save_result
      response = magic_action("SaveResult", nil	 )
      return response.body[:magic_response][:magic_result][:diffgram][:saveresultresponse][:saveresultinfo]
    end

    def save_rx
      response = magic_action("SaveRX", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:saverxresponse][:saverxinfo]
    end

    def save_simple_encounter
      response = magic_action("SaveSimpleEncounter", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savesimpleencounterresponse][:savesimpleencounterinfo]
    end

    def save_simple_rx
      response = magic_action("SaveSimpleRX", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savesimplerxresponse][:savesimplerxinfo]
    end

    def save_specialist
      response = magic_action("SaveSpecialist", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savespecialistresponse][:savespecialistinfo]
    end

    def save_task
      response = magic_action("SaveTask", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savetaskresponse][:savetaskinfo]
    end

    def save_task_status
      response = magic_action("SaveTaskStatus", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savetaskstatusresponse][:savetaskstatusinfo]
    end

    def save_unstructured_document
      response = magic_action("SaveUnstructuredDocument", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:saveunstructureddocumentresponse][:saveunstructureddocumentinfo]
    end

    def save_v10_doc_signature
      response = magic_action("SaveV10DocSignature", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savev10docsignatureresponse][:saveV10docsignatureinfo]
    end

    def save_v11_note
      response = magic_action("SaveV11Note", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savev11noteresponse][:savev11noteinfo]
    end

    def save_vitals
      response = magic_action("SaveVitals", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:savevitalsresponse][:savevitalsinfo]
    end

    def search_charge_codes
      response = magic_action("SearchChargeCodes", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:searchchargecodesresponse][:searchchargecodesinfo]
    end

    def search_diagnosis_codes
      response = magic_action("SearchDiagnosisCodes", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:searchdiagnosiscodesresponse][:searchdiagnosiscodesinfo]
    end

    def search_meds
      response = magic_action("SearchMeds", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:searchmedsresponse][:searchmedsinfo]
    end

    def search_patients
      response = magic_action("SearchPatients", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:searchpatientsresponse][:searchpatientsinfo]
    end

    def search_patients_rxhub5
      response = magic_action("SearchPatientsRXHub5", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:searchpatientsrxhub5response][:searchpatientsrxhub5info]
    end

    def search_pharmacies
      response = magic_action("SearchPharmacies", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:searchpharmaciesresponse][:searchpharmaciesinfo]
    end

    def search_problem_codes
      response = magic_action("SearchProblemCodes", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:searchproblemcodesresponse][:searchproblemcodesinfo]
    end

    def update_encounter
      response = magic_action("UpdateEncounter", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:updateencounterresponse][:updateencounterinfo]
    end

    def update_referral_order_status
      response = magic_action("UpdateReferralOrderStatus", nil	 )
      return response.body[:magic_response][:magic_result][:diffgram][:updatereferralorderstatusresponse][:updatereferralorderstatusinfo]
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
    # #   response = magic_action("Get#{attrs.camelize}", nil, *args)
    # #   return response.body[:magic_response][:magic_result][:diffgram]["#{symname}response".to_sym]["#{symname}info".to_sym]
    # # end
    
  end
end