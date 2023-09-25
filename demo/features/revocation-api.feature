Feature: ACA-Py Revocation API 

   @GHA
   Scenario Outline: Using revocation api, issue and revoke credentials
      Given we have "3" agents
         | name  | role     | capabilities        |
         | Acme  | issuer   | <Acme_capabilities> |
         | Faber | verifier | <Acme_capabilities> |
         | Bob   | prover   | <Bob_capabilities>  |
      And "<issuer>" and "Bob" have an existing connection
      And "Bob" has an issued <Schema_name> credential <Credential_data> from "<issuer>"
      And "<issuer>" revokes the credential
      And "Faber" and "Bob" have an existing connection
      When "Faber" sends a request for proof presentation <Proof_request> to "Bob"
      Then "Faber" has the proof verification fail

      Examples:
         | issuer | Acme_capabilities                          | Bob_capabilities | Schema_name       | Credential_data   | Proof_request     |
         | Acme   | --revocation --public-did                  |                  | driverslicense_v2 | Data_DL_MaxValues | DL_age_over_19_v2 |

   @GHA
   Scenario Outline: Using revocation api, issue, revoke credentials and publish
      Given we have "3" agents
         | name  | role     | capabilities        |
         | Acme  | issuer   | <Acme_capabilities> |
         | Faber | verifier | <Acme_capabilities> |
         | Bob   | prover   | <Bob_capabilities>  |
      And "<issuer>" and "Bob" have an existing connection
      And "Bob" has an issued <Schema_name> credential <Credential_data> from "<issuer>"
      And "<issuer>" has written the credential definition for <Schema_name> to the ledger
      And "<issuer>" has written the revocation registry definition to the ledger ignore count
      And "<issuer>" has written the revocation registry entry transaction to the ledger
      And "<issuer>" revokes the credential without publishing the entry
      And "<issuer>" authors a revocation registry entry publishing transaction
      And "Faber" and "Bob" have an existing connection
      When "Faber" sends a request for proof presentation <Proof_request> to "Bob"
      Then "Faber" has the proof verification fail
      Then "Bob" can verify the credential from "<issuer>" was revoked
      Examples:
         | issuer | Acme_capabilities                          | Bob_capabilities | Schema_name       | Credential_data   | Proof_request     |
         | Acme   | --revocation --public-did                  |                  | driverslicense_v2 | Data_DL_MaxValues | DL_age_over_19_v2 |

   @GHA-Anoncreds-break
   Scenario Outline: Without endorser: issue, revoke credentials, manually create revocation registries
      Given we have "3" agents
         | name  | role     | capabilities        |
         | Acme  | issuer   | <Acme_capabilities> |
         | Faber | verifier | <Acme_capabilities> |
         | Bob   | prover   | <Bob_capabilities>  |
      And "<issuer>" and "Bob" have an existing connection
      And Without endorser, "<issuer>" authors a schema transaction with <Schema_name>
      And "<issuer>" has written the schema <Schema_name> to the ledger
      And Without endorser, "<issuer>" authors a credential definition transaction with <Schema_name>'
      And "<issuer>" has written the credential definition for <Schema_name> to the ledger
      And Without endorser, "<issuer>" authors a revocation registry definition transaction for the credential definition matching <Schema_name>
      And Without endorser, "<issuer>" has written the revocation registry definition to the ledger
      And "<issuer>" has activated the tails file, and uploaded it to the tails server
      And Without endorser, "<issuer>" authors a revocation registry entry transaction for the credential definition matching <Schema_name>
      And "<issuer>" has written the revocation registry entry transaction to the ledger
      And "<issuer>" offers a credential with data <Credential_data>
      Then "Bob" has the credential issued
      And "<issuer>" revokes the credential without publishing the entry
      And "<issuer>" authors a revocation registry entry publishing transaction
      And "Faber" and "Bob" have an existing connection
      When "Faber" sends a request for proof presentation <Proof_request> to "Bob"
      Then "Faber" has the proof verification fail
      Then "Bob" can verify the credential from "<issuer>" was revoked
      Examples:
         | issuer | Acme_capabilities                          | Bob_capabilities | Schema_name       | Credential_data   | Proof_request     |
         | Acme   | --revocation --public-did --did-exchange   |                  | driverslicense_v2 | Data_DL_MaxValues | DL_age_over_19_v2 |
