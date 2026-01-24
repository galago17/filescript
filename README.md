# Project Template Scripts

**newfile**: create new file  
**newdir**: create new directory  
**move**: move/rename file  
**include**: load another template file and run it  
This does allow you to create infinite loops. Use with caution  
**delpath**: delete file or directory 
``<name>``: Get value of variable ``name``. If it doesn't exist yet, prompt for a value. 

**add**: Append line to active file  
**addstr**: This keyword was added so as not to overcomplicate by implementing escape characters.
It concatenates strings and appends them like **add**, e.g. addstr ``addstr "hello " <name> "!"``  

The active file is the last file that an action was performed on, e.g. rename, creation, etc. except for deletion.  
**select**: Manually change active file.  

``<``: Start block: Blocks are a shortcut for ``add`` when you don't need to use variables in the file content  
``>``: Close block.  
Content in blocks is added to the active file verbatim.  
Each block indicator has to be on its own line.  

# CLI Usage

Clone repo and run build.lisp with SBCL to get executable, or if you trust me download the executable
in the top level folder of the repo, which will be up to date. 

``filescript filepath``  

# Example

Java Project Template
```
# Create a new file project/src/pkg/Main.java, where project and pkg are variables.  
newfile <project>/src/<pkg>/Main.java

# Append to active file (Main.java): Concatenate "package", the variable pkg, and ";"  
add package <pkg>;

# Enter block mode (append block to active file)
<
public class Main {
  public static void main (String[] args) {
    System.out.println("Hello World");
  }
}
>
# Exit block mode (comment placed outside block to avoid adding it to file).
```
When run, the code above would prompt for a project and package name, and then create project/src/package/Main.java with the correct package declaration and a Hello World program. 
