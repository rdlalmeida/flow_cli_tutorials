/*

    KittyVarse.cdc

    The KittyVerse contract defines two types of NFTs. One is a KittyHat, which represents a special hat, and the 
    second is the Kitty resource, which can own Kitty Hats.

    You can put the hats on the cats and then call a hat function that tips the hats and prints a fun message.

    This is a simple example of how Cadence supports extensibility for smart contracts, but the language will soon
    support even more powerful versions of this.

*/

pub contract KittyVerse {
    // Set the contract-wide paths at this point
    pub let kittyCollectionStorage: StoragePath
    pub let kittyCollectionPublic: PublicPath

    pub let kittyMinterStorage: StoragePath
    // pub let kittyMinterPublic: PublicPath

    // Intiialization function for the main contracts
    init() {
        self.kittyCollectionStorage = /storage/kittyCollection
        self.kittyCollectionPublic = /public/kittyCollection

        self.kittyMinterStorage = /storage/kittyMinter
        // self.kittyMinterPublic = /public/kittyMinter

        // There is going to be a single KittyAdministrator created and saved. To ensure this, do it during this contract's initialization
        let kittyAdmin: @KittyVerse.KittyAdministrator <- create KittyAdministrator()

        // Clean the Administrator storage in case we want to re-deploy this contract (issues are going to arrive when a new Administrator is saved
        // to the same path). In this case, since the Administrator is used only to mint Kitties and KittyItems, there's no issue in rewriting it
        destroy self.account.load<@AnyResource>(from: self.kittyMinterStorage)

        // Save it to storage immediately
        self.account.save<@KittyVerse.KittyAdministrator>(<- kittyAdmin, to: KittyVerse.kittyMinterStorage)
    }

    // Define another Admin Minter resource. This one is the one that can mint new Kitties and Kitty items (both functions are set to this resource
    // and locked to the account that deploys this contract - henceforth know as admin
    pub resource KittyAdministrator {
        // Create a new hat
        pub fun createHat(id: Int, name: String): @KittyHat {
            return <- create KittyHat(_name: name)
        }

        pub fun createKitty(name: String): @Kitty {
            return <- create Kitty(_kittyName: name)
        }
    }

    // Define a Resource Receiver interface to impose into our collection
    pub resource interface KittyReceiver {
        pub fun depositKitten(kitten: @Kitty)

        pub fun getKittiesIds(): [UInt64]

        pub fun idExists(id: UInt64): Bool
    }

    // And now the proper Colection Resource to save the Kittens
    pub resource KittyCollection: KittyReceiver {
        pub var ownedKitties: @{UInt64: Kitty}
        
        // Simple function to deposit a new Kitty in this collection
        pub fun depositKitten(kitten: @Kitty) {
            let randomKitten: @AnyResource? <- self.ownedKitties[kitten.id] <- kitten

            destroy randomKitten
        }

        // This one returns an array of UInt64
        pub fun getKittiesIds(): [UInt64] {
            return self.ownedKitties.keys
        }

        // Test if a Kitten is already stored under that key
        pub fun idExists(id: UInt64): Bool {
            // Test if there is a Kitty saved under that key by extracting it and comparing it with nil.
            return self.ownedKitties[id] != nil
        }

        // This one simply prints out the ids and 
        pub fun getAllKitties() {}

        pub fun getAllKittiesAndHats() {}

        init() {
            // Initiate the collection as an empty dictionary
            self.ownedKitties <- {}
        }

        destroy() {
            destroy self.ownedKitties
        }
    }

    // Traditional Collection creating function, as usual
    pub fun createEmptyKittyCollection(): @KittyVerse.KittyCollection{KittyVerse.KittyReceiver} {
        return <- create KittyVerse.KittyCollection()
    }

    // KittyHat is a special resource type that represents a hat
    pub resource KittyHat {
        pub let id: UInt64
        pub let name: String

        init(_name: String) {
            self.id = self.uuid
            self.name = _name
        }

        // An example of a function someone might put in their hat resource
        pub fun tipHat(): String {
            if (self.name) == "Cowboy Hat" {
                return "Howdy Y'all"
            }
            else if (self.name == "Top Hat") {
                return "Greetings, fellow aristocats!"
            }

            return "Hello"
        }
    }

    pub resource Kitty {
    
        pub let id: UInt64
        pub let kittyName: String

        // Place where the Kitty hats are stored
        pub var items: @{String: KittyHat}

        init(_kittyName: String) {
            self.id = self.uuid
            self.kittyName = _kittyName
            self.items <- {}
        }

        pub fun getKittyItems(): @{String: KittyHat} {
            var other: @{String: KittyHat} <- {}
            self.items <-> other
            return <- other
        }

        pub fun setKittyItems(items: @{String: KittyHat}) {
            var other: @{String: KittyHat} <- items
            self.items <-> other
            destroy other
        }

        pub fun removeKittyItem(key: String): @KittyHat? {
            var removed: @KittyVerse.KittyHat <- self.items.remove(key: key) ??
                panic(
                    "Unable to remove KittyItem with id #"
                    .concat(key)
                    .concat(". The item does not exist!")
                )
            return <- removed
        }

        destroy() {
            destroy self.items
        }
    }
}