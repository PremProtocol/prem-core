import "@stdlib/deploy";

contract MainContract with Deployable {
    val: Int as int32;

    init() {
        self.val = 0;    
    }

    receive("increment") {
        self.val = self.val + 1;
    }

    get fun value(): Int {
        return self.val;
    }
}
