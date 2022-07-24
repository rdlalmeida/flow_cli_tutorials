import ExampleToken from "../contracts/ExampleToken.cdc"

pub fun main() {
    // A simple array with all the accounts currently defined in the emulator
    // let emulatorAccounts: [Address] = [0xf8d6e0586b0a20c7, 0xf3fcd2c1a78f5eee, 0x179b6b1cb6755e31, 0xe03daebed8ca0615]
    let emulatorAccounts: [Address] = [0xf8d6e0586b0a20c7, 0x01cf0e2f2f715450, 0x179b6b1cb6755e31, 0xf3fcd2c1a78f5eee]
    
    for emulator_account in emulatorAccounts {
        // Try to retrieve a reference to a Vault from the standard storage
        let vault_ref: &ExampleToken.Vault{ExampleToken.Provider, ExampleToken.Receiver, ExampleToken.Balance}? = 
            getAccount(emulator_account).getCapability<&ExampleToken.Vault{ExampleToken.Receiver, ExampleToken.Provider, ExampleToken.Balance}>(ExampleToken.VaultPublicPath).borrow()

        // Don't panic in this case. Try to get the reference and if a nil gets back, ignore this account and move to the next one
        if (vault_ref == nil) {
            log(
                "Account "
                .concat(emulator_account.toString())
                .concat(" does not h0xe03daebed8ca0615as a Vault configured!")
                )
        }
        else {
            let proper_vault_ref = (vault_ref as &ExampleToken.Vault{ExampleToken.Receiver, ExampleToken.Provider, ExampleToken.Balance}?)!
            let balance = proper_vault_ref.getBalance()

            log(
                "Account "
                .concat(emulator_account.toString())
                .concat(" has a Vault stored with ")
                .concat(balance.toString())
                .concat(" tokens in it")
                )
        }
    }

    // And now for the contract's total supply (so that we can confirm that tokens are not created out of nothing)
    log("Contract's total supply: ".concat(ExampleToken.totalSupply.toString()).concat(" tokens"))
}