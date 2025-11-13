## Brief overview
This rule defines the requirement for new Apex class files to include a comment with the creation date at the very beginning of the file.

## File structure requirements
- All new Apex classes must include a comment on line 1 with the creation date
- The comment should be in the format: // Created on YYYY-MM-DD
- This comment must be the first line of the file, before any package or class declarations

## Example
```apex
// Created on 2025-11-12
public class ARV_AccountFetcher {
    // Class implementation
}
```

## Trigger  
- When creating any new Apex class file
- This applies to all new class files in the force-app/main/default/classes directory
