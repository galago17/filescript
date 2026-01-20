# Project Template Scripts

**cnf**: create new file  
**cnd**: create new directory  
**ren**: rename file  
**inc**: load another template file and run it  
This does allow you to create infinite loops. Use with caution  
**del**: delete file  
``<name>``: Get value of variable ``name``. If it doesn't exist yet, prompt for a value. 
**add**: Append line to current file  
The current file is the last file that an action was performed on, e.g. rename, creation, etc. except for deletion.  
``<``: Start block: Blocks are a shortcut for ``add`` when you don't need to use variables in the file content  
``>``: Close block.  

Each block indicator has to be on its own line.  

# CLI Usage

``filescript mode filepath``  

mode == template ->  

``filepath`` will be relative to ~/.local/share/filescript, and the .fscript extension
will be added automatically. For example, ``filescript template java`` would run ~/.local/share/filescript/java.fscript.

mode == local ->  
``filepath`` will be relative to current working directory. .fscript extension is necessary. 

# Example

Java Project Template
```
# Create a new file project/pkg/Main.java, where project and pkg are variables.  
cnf <project>/<pkg>/Main.java

# Append to active file (Main.java): Concatenate "package", the variable pkg, and ";"  
add package <pkg>;

# Enter block mode (append block to active file)
<
public class Main {
  public static void main () {
    System.out.println("Hello World");
  }
}
>
# Exit block mode (a comment in block mode will be added to the file).
```
When run, the code above would prompt for a project and package name, and then create project/package/Main.java with the correct package declaration and a Hello World program. 
