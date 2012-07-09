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
        HTTPI.log = false
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
  
    def magic_action(action, user_id=self.user, patient_id = "", param_1=nil, param_2=nil, param_3=nil, param_4=nil, param_5=nil, param_6=nil, data=nil)
      begin
        response = self.client.request("Magic", xmlns: "http://www.allscripts.com/Unity") do
          http.headers = {"Accept-Encoding" => "gzip, deflate", "SOAPAction" => "http://www.allscripts.com/Unity/IUnityService/Magic", "Content-Type" =>  "text/xml; charset=UTF-8"}
          soap.body = {
            "Action" => action,
            "UserID" => user_id,
            "Appname" => self.app,
            "PatientID" => patient_id,
            "Token" => self.security_token,
            "Parameter1" => param_1,
            "Parameter2" => param_2,
            "Parameter3" => param_3,
            "Parameter4" => param_4,
            "Parameter5" => param_5,
            "Parameter6" => param_6,
            "data" => data,
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

    def commit_charges(user_id, encounter_id, side_de)
      response = magic_action("CommitCharges", user_id, patient_id, encounter_id, site_de)
      return response.body[:magic_response][:magic_result][:diffgram][:commitchargesresponse][:commitchargesinfo]
    end
  
    def echo(user_id, patient_id="", param_1=nil, param_2=nil, param_3=nil, param_4=nil, param_5=nil, param_6=nil)
      response = magic_action("Echo", user_id, patient_id, param_1, param_2, param_3, param_4, param_5, param_6)
      return response.body[:magic_response][:magic_result][:diffgram][:echoresponse][:echoinformation]
    end
  
    def get_account
      response = magic_action("GetAccount")
      return response.body[:magic_response][:magic_result][:diffgram][:getaccountresponse][:getaccountinfo]
    end
      
    def get_changed_patients(start_time=nil)
      response = magic_action("GetChangedPatients", nil, nil, start_time)
      return response.body[:magic_response][:magic_result][:diffgram][:getchangedpatientsresponse][:getchangedpatientsinfo].map(&:patientid)
    end
      
    def get_charge_info_by_username(user_id, username_filter=nil)
      response = magic_action("GetChargeInfoByUsername", user_id, nil, username_filter)
      return response.body[:magic_response][:magic_result][:diffgram][:getchargeinfobyusernameresponse][:getchargeinfobyusernameinfo]
    end
      
    def get_charges(user_id, encounter_id=nil)
      response = magic_action("GetCharges", user_id, nil, encounter_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getchargesresponse][:getchargesinfo]
    end
      
    def get_delegates(user_id)
      response = magic_action("GetDelegates", user_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getdelegatesresponse][:getdelegatesinfo]
    end
      
    def get_dictionary(user_id, dictionary_name, site=nil)
      response = magic_action("GetDictionary", user_id, nil, dictionary_name, site)
      return response.body[:magic_response][:magic_result][:diffgram][:getdictionaryresponse][:getdictionaryinfo]
    end
      
    def get_dictionary_sets(group_name, dictionary_set_name)
      response = magic_action("GetDictionarySets", nil, nil, group_name, dictionary_set_name)
      return response.body[:magic_response][:magic_result][:diffgram][:getdictionarysetsresponse][:getdictionarysetsinfo]
    end
      
    def get_doc_template(user_id, section, template)
      response = magic_action("GetDocTemplate", user_id, nil, section, template)
      return response.body[:magic_response][:magic_result][:diffgram][:getdoctemplateresponse][:getdoctemplateinfo]
    end
      
    def get_document_by_accession(patient_id=nil, accession_num)
      response = magic_action("GetDocumentByAccession", nil, patient_id, accession_num)
      return response.body[:magic_response][:magic_result][:diffgram][:getdocumentbyaccensionresponse][:getdocumentbyaccensioninfo]
    end
      
    def get_document_image(user_id, patient_id=nil, document_id)
      response = magic_action("GetDocumentImage", user_id, patient_id, document_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getdocumentimageresponse][:getdocumentimageinfo]
    end
      
    def get_documents(user_id, patient_id, document_id, document_type=nil, start_date=nil, end_date=nil)
      response = magic_action("GetDocuments", user_id, patient_id, start_date, end_date, document_id, document_type)
      return response.body[:magic_response][:magic_result][:diffgram][:getdocumentsresponse][:getdocumentsinfo]
    end
      
    def get_document_type(doc_type=nil)#could be "Chart", "Consult", "SpecReport", "ChartCopy" or nil
      response = magic_action("GetDocumentType", nil, nil, doc_type)
      return response.body[:magic_response][:magic_result][:diffgram][:getdocumenttyperesponse][:getdocumenttypeinfo]
    end
      
    def get_dur(user_id, patient_id, dur_type, client_id, rx_data)
      response = magic_action("GetDUR", user_id, patient_id, dur_type, client_id, rx_data)
      return response.body[:magic_response][:magic_result][:diffgram][:getdurresponse][:getdurinfo]
    end
      
    def get_encounter(user_id, patient_id, encounter_type, encounter_time, force_new_encounter, match_provider_flag)
      response = magic_action("GetEncounter", user_id, patient_id, encounter_type, encounter_time, force_new_encounter, match_provider_flag)
      return response.body[:magic_response][:magic_result][:diffgram][:getencounterresponse][:getencounterinfo]
    end
      
    def get_encounter_date(patient_id, encounter_id)
      response = magic_action("GetEncounterDate", nil, patient_id, encounter_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getencounterdateresponse][:getencounterdateinfo]
    end
      
    def get_encounter_list(user_id, patient_id, encounter_type, date, future_days, show_previous_encounters, billing_provider)
      response = magic_action("GetEncounterList", user_id, patient_id, encounter_type, date, future_days, show_previous_encounters, billing_provider)
      return response.body[:magic_response][:magic_result][:diffgram][:getencounterlistresponse][:getencounterlistinfo]
    end
      
    def get_hie_document(patient_id)
      response = magic_action("GetHIEDocument", nil, patient_id)
      return response.body[:magic_response][:magic_result][:diffgram][:gethiedocumentresponse][:gethiedocumentinfo]
    end
      
    def get_last_patient
      response = magic_action("GetLastPatient")
      return response.body[:magic_response][:magic_result][:diffgram][:getlastpatientresponse][:getlastpatientinfo]
    end
      
    def get_list_of_dictionaries
      response = magic_action("GetListOfDictionaries")
      return response.body[:magic_response][:magic_result][:diffgram][:getlistofdictionariesresponse][:getlistofdictionariesinfo]
    end
    
    def get_medication_by_trans_id(user_id, patient_id, trans_id)
      response = magic_action("GetMedicationByTransID", user_id, patient_id, trans_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getmedicationbytransidresponse][:getmedicationbytransidinfo]      
    end
    
    def get_order_history(user_id, item_id)
      response = magic_action("GetOrderHistory", user_id, nil, item_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getorderhistoryresponse][:getorderhistoryinfo]
    end
      
    def get_organization_id
      response = magic_action("GetOrganizationID")
      return response.body[:magic_response][:magic_result][:diffgram][:getorganizationidresponse][:getorganizationidinfo]
    end
      
    def get_packages(user_id, org_name)
      response = magic_action("GetPackages", user_id, nil, org_name)
      return response.body[:magic_response][:magic_result][:diffgram][:getpackagesresponse][:getpackagesinfo]
    end
      
    def get_patient(user_id, patient_id, include_pic)
      response = magic_action("GetPatient", user_id, patient_id, include_pic)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientresponse][:getpatientinfo]
    end
    def get_patient_by_mrn(user_id, mrn)
      response = magic_action("GetPatientByMRN", user_id, nil, mrn)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientbymrnresponse][:getpatientbymrninfo]
    end
    def get_patient_cda(patient_id, organization_id=nil, appgroup=nil)
      response = magic_action("GetPatientCDA", nil, patient_id, organization_id, appgroup)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientcdaresponse][:getpatientcdainfo]
    end
      
    def get_patient_diagnosis(user_id, patient_id, encounter_date, encounter_type_mnemonic, encounter_date_rage, encounter_id)
      response = magic_action("GetPatientDiagnosis", user_id, patient_id, encounter_date, encounter_type_mnemonic, encounter_date_rage, encounter_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientdiagnosisresponse][:getpatientdiagnosisinfo]
    end
      
    def get_patient_full(patient_id, mrn, org_id, order_id)
      response = magic_action("GetPatientFull", nil, patient_id, mrn, org_id, order_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientfullresponse][:getpatientfullinfo]
    end
      
    def get_patient_ids(patient_id)
      response = magic_action("GetPatientIDs", nil, patient_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientidsresponse][:getpatientidsinfo]
    end
      
    def get_patient_list(location_code, appt_date)
      response = magic_action("GetPatientList", nil, nil, location_code, appt_date)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientlistresponse][:getpatientlistinfo]
    end
      
    def get_patient_locations(user_id, user_xml=nil) #user_xml needs to be better defined and broken down into true params
      response = magic_action("GetPatientLocations", user_id, nil, user_xml)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientlocationsresponse][:getpatientlocationsinfo]
    end
    def get_patient_pharmacies(user_id, patient_id)
      response = magic_action("GetPatientPharmacies", user_id, patient_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientpharmaciesresponse][:getpatientpharmaciesinfo]
    end
      
    def get_patient_problems(patient_id, show_by_encounter_flag=nil, assessed=nil, encounter_id=nil, medcin_id=nil)
      response = magic_action("GetPatientProblems", nil, patient_id, show_by_encounter_flag, assessed, encounter_id, medcin_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientproblemsresponse][:getpatientproblemsinfo]
    end
      
    def get_patients_by_icd9(icd_9, start_date, end_date)
      response = magic_action("GetPatientsByICD9", nil, nil, icd_9, start_date, end_date)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientsbyicd9response][:getpatientsbyicd9info]
    end
      
    def get_patient_sections(user_id, patient_id, months)
      response = magic_action("GetPatientSections", user_id, patient_id, months)
      return response.body[:magic_response][:magic_result][:diffgram][:getpatientsectionsresponse][:getpatientsectionsinfo]
    end
      
    def get_provider(provider_id, user_name)
      response = magic_action("GetProvider")
      return response.body[:magic_response][:magic_result][:diffgram][:getproviderresponse][:getproviderinfo]
    end
      
    def get_providers(security_filter=nil, name_filter=nil)
      response = magic_action("GetProviders")
      return response.body[:magic_response][:magic_result][:diffgram][:getprovidersresponse][:getprovidersinfo]
    end
    
    def get_ref_providers_by_specialty(user_id, search)
      response = magic_action("GetRefProvidersBySpecialty", user_id, nil, search)
      return response.body[:magic_response][:magic_result][:diffgram][:getrefprovidersbyspecialtyresponse][:getrefprovidersbyspecialtyinfo]
    end
    
    def get_rounding_list_entries(user_id, patient_list_id, sort_field, sort_order, org_id, timezone_offset)
      response = magic_action("GetRoundingListEntries", user_id, nil, patient_list_id, sort_field, sort_order, org_id, timezone_offset)
      return response.body[:magic_response][:magic_result][:diffgram][:getroundinglistentriesresponse][:getroundinglistentriesinfo]
    end
    
    def get_rounding_lists(user_id, org_id)
      response = magic_action("GetRoundingLists", user_id, nil, org_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getroundinglistsresponse][:getroundinglistsinfo]
    end
    
    def get_rx_favs(user_id, patient_id)
      response = magic_action("GetRXFavs", user_id, patient_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getrxfavsresponse][:getrxfavsinfo]
    end
    
    def get_schedule(date)
      response = magic_action("GetSchedule", user_id, nil, date)
      return response.body[:magic_response][:magic_result][:diffgram][:scheduleresponse][:scheduleinfo]
    end
    
    def get_server_info
      response = magic_action("GetServerInfo")
      return response.body[:magic_response][:magic_result][:diffgram][:getserverinforesponse][:getserverinfoinfo]
    end
    
    def get_sigs(user_id, ddi, favs)
      response = magic_action("GetSigs", user_id, nil, ddi, favs)
      return response.body[:magic_response][:magic_result][:diffgram][:getsigsresponse][:getsigsinfo]
    end
    
    def get_site_config(site_id)
      response = magic_action("GetSiteConfig", nil, nil, site_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getsiteconfigresponse][:getsiteconfiginfo]
    end
    def get_task(user_id, trans_id)
      response = magic_action("GetTask", user_id, nil, trans_id)
      return response.body[:magic_response][:magic_result][:diffgram][:gettaskresponse][:gettaskinfo]
    end
    def get_task_list(user_id)
      response = magic_action("GetTaskList", user_id)
      return response.body[:magic_response][:magic_result][:diffgram][:gettasklistresponse][:gettasklistinfo]
    end
    def get_token_validation(sso_token)
      response = magic_action("GetTokenValidation", nil, nil, sso_token)
      return response.body[:magic_response][:magic_result][:diffgram][:gettokenvalidationresponse][:gettokenvalidationinfo]
    end
    def get_user_authentication(user_id, password, client_id, app_version)
      response = magic_action("GetUserAuthentication", user_id, nil, password, client_id, app_version)
      return response.body[:magic_response][:magic_result][:diffgram][:getuserauthenticationresponse][:getuserauthenticationinfo]
    end
    def get_user_id(user_id)
      response = magic_action("GetUserID", user_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getuseridresponse][:getuseridinfo]
    end
    def get_user_security(user_id_num, org_id)
      response = magic_action("GetUserSecurity", nil, nil, user_id_num, org_id)
      return response.body[:magic_response][:magic_result][:diffgram][:getusersecurityresponse][:getusersecurityinfo]
    end
    def get_vaccine_manufacturers
      response = magic_action("GetVaccineManufacturers")
      return response.body[:magic_response][:magic_result][:diffgram][:getvaccinemanufacturersresponse][:getvaccinemanufacturersinfo]
    end
    def get_vitals #returns xml description of all vitals forms used in EHR
      response = magic_action("GetVitals")
      return response.body[:magic_response][:magic_result][:diffgram][:getvitalsresponse][:getvitalsinfo]
    end
    
    def make_task(task_type, target_user, work_object_id)
      response = magic_action("MakeTask", nil, nil, task_type, target_user, work_object_id)
      return response.body[:magic_response][:magic_result][:diffgram][:maketaskresponse][:maketaskinfo]
    end    
    
    def save_admin_task(user_id, task_xml) #better define task_xml
      response = magic_action("SaveAdminTask", nil)
      return response.body[:magic_response][:magic_result][:diffgram][:saveadmintaskresponse][:saveadmintaskinfo]
    end

    def save_allergy(user_id, patient_id, allergy_xml)
      response = magic_action("SaveAllergy", user_id, patient_id, allergy_xml)
      return response.body[:magic_response][:magic_result][:diffgram][:saveallergyresponse][:saveallergyinfo]
    end

    def save_ced(ced_params, ced_text)
      response = magic_action("SaveCED", nil, nil, ced_params, ced_text)
      return response.body[:magic_response][:magic_result][:diffgram][:savecedresponse][:savecedinfo]
    end

    def save_charge(user_id, charge_id, encounter_id, charge_code_de, payload_xml)
      response = magic_action("SaveCharge", user_id, nil, "", charge_id, encounter_id, charge_code_de, payload_xml)
      return response.body[:magic_response][:magic_result][:diffgram][:savechargeresponse][:savechargeinfo]
    end

    def save_chart_view_audit(user_id, xml_payload)
      response = magic_action("SaveChartViewAudit", user_id, nil, xml_payload)
      return response.body[:magic_response][:magic_result][:diffgram][:savechartviewauditresponse][:savechartviewauditinfo]
    end

    def save_diagnosis(user_id, encounter_id, icd9, display_order, free_text)
      response = magic_action("SaveDiagnosis", user_id, nil, encounter_id, icd9, display_order, free_text)
      return response.body[:magic_response][:magic_result][:diffgram][:savediagnosisresponse][:savediagnosisinfo]
    end

    def save_document_image(user_id, patient_id, document_param, data)
      response = magic_action("SaveDocumentImage", user_id, patient_id, document_param, nil, nil, nil , nil, nil, data)
      return response.body[:magic_response][:magic_result][:diffgram][:savedocumentimageresponse][:savedocumentimageinfo]
    end

    def save_er_note(user_id, patient_id, note, er_id)
      response = magic_action("SaveERNote", user_id, patient_id, note, er_id)
      return response.body[:magic_response][:magic_result][:diffgram][:saveernoteresponse][:saveernoteinfo]
    end

    def save_hie_document(user_id, patient_id, xml_params, ced_xml)
      response = magic_action("SaveHIEDocument", user_id, patient_id, xml_params, ced_xml)
      return response.body[:magic_response][:magic_result][:diffgram][:savehiedocumentresponse][:savehiedocumentinfo]
    end

    def save_history(user_id, patient_id, xml_params)
      response = magic_action("SaveHistory", user_id, patient_id, xml_params)
      return response.body[:magic_response][:magic_result][:diffgram][:savehistoryresponse][:savehistoryinfo]
    end

    def save_immunization(user_id, patient_id, xml)
      response = magic_action("SaveImmunization", user_id, patient_id, xml)
      return response.body[:magic_response][:magic_result][:diffgram][:saveimmunizationresponse][:saveimmunizationinfo]
    end

    def save_note(user_id, patient_id, note, doc_type, doc_status, rtf_ok)
      response = magic_action("SaveNote", user_id, patient_id, note, doc_type, doc_status, rtf_ok)
      return response.body[:magic_response][:magic_result][:diffgram][:savenoteresponse][:savenoteinfo]
    end

    def save_patient(user_id, patient_id, xml)
      response = magic_action("SavePatient", user_id, patient_id, xml)
      return response.body[:magic_response][:magic_result][:diffgram][:savepatientresponse][:savepatientinfo]
    end

    def save_patient_location(user_id, patient_id, xml)
      response = magic_action("SavePatientLocation", user_id, patient_id, xml)
      return response.body[:magic_response][:magic_result][:diffgram][:savepatientlocationresponse][:savepatientlocationinfo]
    end

    def save_problem(patient_id, problem_type_id, problem_id, severity, type, xml_payload)
      response = magic_action("SaveProblem", nil, patient_id, problem_type_id, problem_id, severity, type, xml_payload)
      return response.body[:magic_response][:magic_result][:diffgram][:saveproblemresponse][:saveprobleminfo]
    end

    def save_problems_data(user_id, patient_id, xml_params)
      response = magic_action("SaveProblemsData", user_id, patient_id, xml_params)
      return response.body[:magic_response][:magic_result][:diffgram][:saveproblemsdataresponse][:saveproblemsdatainfo]
    end

    def save_ref_provider(xml)
      response = magic_action("SaveRefProvider", nil, nil, xml)
      return response.body[:magic_response][:magic_result][:diffgram][:saverefproviderresponse][:saverefproviderinfo]
    end

    def save_result(result_xml)
      response = magic_action("SaveResult", nil, nil, result_xml)
      return response.body[:magic_response][:magic_result][:diffgram][:saveresultresponse][:saveresultinfo]
    end

    def save_rx(user_id, patient_id, rxxml)
      response = magic_action("SaveRX", user_id, patient_id, rxxml)
      return response.body[:magic_response][:magic_result][:diffgram][:saverxresponse][:saverxinfo]
    end

    def save_simple_encounter(user_id, patient_id, encounter_type, datetime)
      response = magic_action("SaveSimpleEncounter", user_id, patient_id, encounter_type, datetime)
      return response.body[:magic_response][:magic_result][:diffgram][:savesimpleencounterresponse][:savesimpleencounterinfo]
    end

    def save_simple_rx(user_id, patient_id, med_fav, pharm_id)
      response = magic_action("SaveSimpleRX", user_id, patient_id, med_fav, pharm_id)
      return response.body[:magic_response][:magic_result][:diffgram][:savesimplerxresponse][:savesimplerxinfo]
    end

    def save_specialist(specialist_xml)
      response = magic_action("SaveSpecialist", nil, nil, specialist_xml)
      return response.body[:magic_response][:magic_result][:diffgram][:savespecialistresponse][:savespecialistinfo]
    end

    def save_task(patient_id, task_type, target_user, work_object_id, comments)
      response = magic_action("SaveTask", nil, patient_id, task_type, target_user, work_object_id, comments)
      return response.body[:magic_response][:magic_result][:diffgram][:savetaskresponse][:savetaskinfo]
    end

    def save_task_status(user_id, trans_id, param, delegate_id, comment)
      response = magic_action("SaveTaskStatus", user_id, nil, trans_id, param, delegate_id, comment)
      return response.body[:magic_response][:magic_result][:diffgram][:savetaskstatusresponse][:savetaskstatusinfo]
    end

    def save_unstructured_document(user_id, trans_id, param, delegate_id, comment)
      response = magic_action("SaveUnstructuredDocument", user_id, nil, trans_id, param, delegate_id, comment)
      return response.body[:magic_response][:magic_result][:diffgram][:saveunstructureddocumentresponse][:saveunstructureddocumentinfo]
    end

    def save_v10_doc_signature(user_id)
      response = magic_action("SaveV10DocSignature", user_id)
      return response.body[:magic_response][:magic_result][:diffgram][:savev10docsignatureresponse][:saveV10docsignatureinfo]
    end

    def save_v11_note(user_id, patient_id, input_template_id, xml_params, sign)
      response = magic_action("SaveV11Note", user_id, patient_id, input_template_id, xml_params, sign)
      return response.body[:magic_response][:magic_result][:diffgram][:savev11noteresponse][:savev11noteinfo]
    end

    def save_vitals(user_id, patient_id, xml)
      response = magic_action("SaveVitals", user_id, patient_id, xml)
      return response.body[:magic_response][:magic_result][:diffgram][:savevitalsresponse][:savevitalsinfo]
    end

    def search_charge_codes(user_id, patient_id, library, search_string, patient_recent_changes)
      response = magic_action("SearchChargeCodes", user_id, patient_id, library, search_string, patient_recent_changes)
      return response.body[:magic_response][:magic_result][:diffgram][:searchchargecodesresponse][:searchchargecodesinfo]
    end

    def search_diagnosis_codes(user_id, patient_id, library, search_string, row_count, patient_diagnosis_count)
      response = magic_action("SearchDiagnosisCodes", user_id, patient_id, library, search_string, row_count, patient_diagnosis_count)
      return response.body[:magic_response][:magic_result][:diffgram][:searchdiagnosiscodesresponse][:searchdiagnosiscodesinfo]
    end

    def search_meds(user_id, patient_id, search)
      response = magic_action("SearchMeds", user_id, patient_id, search)
      return response.body[:magic_response][:magic_result][:diffgram][:searchmedsresponse][:searchmedsinfo]
    end

    def search_patients(user_id, search)
      response = magic_action("SearchPatients", user_id, nil, search)
      return response.body[:magic_response][:magic_result][:diffgram][:searchpatientsresponse][:searchpatientsinfo]
    end

    def search_patients_rxhub5(first, last, zip, dob, gender)
      response = magic_action("SearchPatientsRXHub5", nil, nil, first, last, zip, dob, gender)
      return response.body[:magic_response][:magic_result][:diffgram][:searchpatientsrxhub5response][:searchpatientsrxhub5info]
    end

    def search_pharmacies(user_id, search)
      response = magic_action("SearchPharmacies", user_id, nil, search)
      return response.body[:magic_response][:magic_result][:diffgram][:searchpharmaciesresponse][:searchpharmaciesinfo]
    end

    def search_problem_codes(user_id, patient_id, library, search)
      response = magic_action("SearchProblemCodes", user_id, patient_id, library, search)
      return response.body[:magic_response][:magic_result][:diffgram][:searchproblemcodesresponse][:searchproblemcodesinfo]
    end

    def update_encounter
      response = magic_action("UpdateEncounter")
      return response.body[:magic_response][:magic_result][:diffgram][:updateencounterresponse][:updateencounterinfo]
    end

    def update_referral_order_status(patient_id, trans_id, new_status)
      response = magic_action("UpdateReferralOrderStatus", nil, patient_id, trans_id, new_status)
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