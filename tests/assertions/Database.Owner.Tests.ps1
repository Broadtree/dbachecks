. "$PSScriptRoot/../../assertions/Database.Owner.ps1"

Describe "Testing Database Owner Assertions" -Tags ValidDatabaseOwner, InvalidDatabaseOwner {
    Context "Validate database owner is valid check" {
        Mock Get-DbcConfigValue { return "correctlogin1","correctlogin2" } -ParameterFilter { $Name -like "policy.validdbowner.name" }
        Mock Get-DbcConfigValue { return "myExcludedDb" } -ParameterFilter { $Name -like "policy.validdbowner.excludedb" }
        
        $testSettings = Get-SettingsForDatabaseOwnerIsValidCheck

        It "The test should pass when the current owner is one of the expected owners" {
            @(@{ 
                Database="db1"
                Owner = "correctlogin1" 
            }) | 
            Assert-DatabaseOwnerIsValid -With $testSettings       
        }
    
        It "The test should pass when the current owner is any of the expected owners" {
            @(@{ 
                Database="db1"
                Owner = "correctlogin2" 
            }) | 
            Assert-DatabaseOwnerIsValid -With $testSettings       
        }

        It "The test should pass even if an excluded database has an incorrect owner" {
            @(@{ 
                Database="db1"
                Owner = "correctlogin1" 
            }, @{
                Database = "myExcludedDb"
                Owner = "incorrectlogin"
            }) | 
            Assert-DatabaseOwnerIsValid -With $testSettings
        }
        
        It "The test should fail when the owner is not one of the expected ones" {
            {
                @(@{ 
                    Database="db1"
                    Owner = "correctlogin1" 
                }, @{ 
                    Database="db2"
                    Owner = "wronglogin" 
                }) |  
                Assert-DatabaseOwnerIsValid -With $testSettings
            } | Should -Throw
        }
    }

    Context "Validate database owner is not invalid check" {
        Mock Get-DbcConfigValue { return "invalidlogin1","invalidlogin2" } -ParameterFilter { $Name -like "policy.invaliddbowner.name" }
        Mock Get-DbcConfigValue { return "myExcludedDb" } -ParameterFilter { $Name -like "policy.invaliddbowner.excludedb" }
        
        $testSettings = Get-SettingsForDatabaseOwnerIsNotInvalidCheck

        It "The test should pass when the current owner is not what is invalid" {
            @(@{ 
                Database="db1"
                Owner = "correctlogin" 
            }) | 
            Assert-DatabaseOwnerIsNotInvalid -With $testSettings
        }

        It "The test should fail when the current owner is the invalid one" {
            {
                @(@{ 
                    Database="db1"
                    Owner = "invalidlogin1" 
                }) | 
                Assert-DatabaseOwnerIsNotInvalid -With $testSettings 
            } | Should -Throw
        }
        
        It "The test should fail when the current owner is any of the invalid ones" {
            {
                @(@{ 
                    Database="db1"
                    Owner = "invalidlogin2" 
                }) | 
                Assert-DatabaseOwnerIsNotInvalid -With $testSettings 
            } | Should -Throw
        }

        It "The test should pass when the invalid user is on an excluded database" {
            @(@{ 
                Database="db1"
                Owner = "correctlogin" 
            },@{ 
                Database="myExcludedDb"
                Owner = "invalidlogin2" 
            }) | 
            Assert-DatabaseOwnerIsNotInvalid -With $testSettings 
        }
    }
}