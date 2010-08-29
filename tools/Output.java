package com.thaiopensource.relaxng.output.rnc;

import com.thaiopensource.relaxng.edit.Annotated;
import com.thaiopensource.relaxng.edit.AnnotationChild;
import com.thaiopensource.relaxng.edit.AnnotationChildVisitor;
import com.thaiopensource.relaxng.edit.AnyNameNameClass;
import com.thaiopensource.relaxng.edit.AttributeAnnotation;
import com.thaiopensource.relaxng.edit.AttributePattern;
import com.thaiopensource.relaxng.edit.ChoiceNameClass;
import com.thaiopensource.relaxng.edit.ChoicePattern;
import com.thaiopensource.relaxng.edit.Combine;
import com.thaiopensource.relaxng.edit.Comment;
import com.thaiopensource.relaxng.edit.Component;
import com.thaiopensource.relaxng.edit.ComponentVisitor;
import com.thaiopensource.relaxng.edit.CompositePattern;
import com.thaiopensource.relaxng.edit.Container;
import com.thaiopensource.relaxng.edit.DataPattern;
import com.thaiopensource.relaxng.edit.DefineComponent;
import com.thaiopensource.relaxng.edit.DivComponent;
import com.thaiopensource.relaxng.edit.ElementAnnotation;
import com.thaiopensource.relaxng.edit.ElementPattern;
import com.thaiopensource.relaxng.edit.EmptyPattern;
import com.thaiopensource.relaxng.edit.ExternalRefPattern;
import com.thaiopensource.relaxng.edit.GrammarPattern;
import com.thaiopensource.relaxng.edit.GroupPattern;
import com.thaiopensource.relaxng.edit.IncludeComponent;
import com.thaiopensource.relaxng.edit.InterleavePattern;
import com.thaiopensource.relaxng.edit.ListPattern;
import com.thaiopensource.relaxng.edit.MixedPattern;
import com.thaiopensource.relaxng.edit.NameClass;
import com.thaiopensource.relaxng.edit.NameClassVisitor;
import com.thaiopensource.relaxng.edit.NameClassedPattern;
import com.thaiopensource.relaxng.edit.NameNameClass;
import com.thaiopensource.relaxng.edit.NotAllowedPattern;
import com.thaiopensource.relaxng.edit.NsNameNameClass;
import com.thaiopensource.relaxng.edit.OneOrMorePattern;
import com.thaiopensource.relaxng.edit.OptionalPattern;
import com.thaiopensource.relaxng.edit.Param;
import com.thaiopensource.relaxng.edit.ParentRefPattern;
import com.thaiopensource.relaxng.edit.Pattern;
import com.thaiopensource.relaxng.edit.PatternVisitor;
import com.thaiopensource.relaxng.edit.RefPattern;
import com.thaiopensource.relaxng.edit.SourceLocation;
import com.thaiopensource.relaxng.edit.TextAnnotation;
import com.thaiopensource.relaxng.edit.TextPattern;
import com.thaiopensource.relaxng.edit.UnaryPattern;
import com.thaiopensource.relaxng.edit.ValuePattern;
import com.thaiopensource.relaxng.edit.VoidVisitor;
import com.thaiopensource.relaxng.edit.ZeroOrMorePattern;
import com.thaiopensource.relaxng.edit.NamespaceContext;
import com.thaiopensource.relaxng.output.OutputDirectory;
import com.thaiopensource.relaxng.output.common.ErrorReporter;
import com.thaiopensource.relaxng.parse.SchemaBuilder;
import com.thaiopensource.util.Utf16;
import com.thaiopensource.util.VoidValue;
import com.thaiopensource.xml.out.CharRepertoire;
import com.thaiopensource.xml.util.WellKnownNamespaces;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Vector;

class Output {
  private final Prettyprinter pp;
  private final CharRepertoire cr;
  private final String indent;
  private final String sourceUri;
  private final OutputDirectory od;
  private final ErrorReporter er;
  private final NamespaceManager.NamespaceBindings nsb;
  private final Map<String, String> datatypeLibraryMap = new HashMap<String, String>();
  private final ComplexityCache complexityCache = new ComplexityCache();
  private final NameClassVisitor<VoidValue> nameClassOutput = new NameClassOutput(true);
  private final NameClassVisitor<VoidValue> noParenNameClassOutput = new NameClassOutput(false);
  private final PatternVisitor<VoidValue> noParenPatternOutput = new PatternOutput(false);
  private final PatternVisitor<VoidValue> patternOutput = new PatternOutput(true);
  private final ComponentVisitor<VoidValue> componentOutput = new ComponentOutput();
  private final AnnotationChildVisitor<VoidValue> annotationChildOutput = new AnnotationChildOutput();
  private final AnnotationChildVisitor<VoidValue> followingAnnotationChildOutput = new FollowingAnnotationChildOutput();
  private boolean isAttributeNameClass;
  private final StringBuffer encodeBuf = new StringBuffer();


  static private final String[] keywords = {
    "attribute", "default", "datatypes", "div", "element", "empty", "external",
    "grammar", "include", "inherit", "list", "mixed", "namespace", "notAllowed",
    "parent", "start", "string", "text", "token"
  };

  static private final Set<String> keywordSet = new HashSet<String>();

  static {
    for (int i = 0; i < keywords.length; i++)
      keywordSet.add(keywords[i]);
  }

  static void output(Pattern p, String encoding, String sourceUri, OutputDirectory od, ErrorReporter er) throws IOException {
    try {
      new Output(sourceUri, encoding, od, er, NamespaceVisitor.createBindings(p)).topLevel(p);
    }
    catch (Prettyprinter.WrappedException e) {
      throw e.getIOException();
    }
  }

  private Output(String sourceUri, String encoding, OutputDirectory od, ErrorReporter er,
                 NamespaceManager.NamespaceBindings nsb) throws IOException {
    this.sourceUri = sourceUri;
    this.od = od;
    this.er = er;
    // Only preserve the input encoding if it's one that can be auto-detected.
    if (encoding != null
        && !encoding.equalsIgnoreCase("UTF-8")
        && !encoding.equalsIgnoreCase("UTF-16")
        && !encoding.equalsIgnoreCase("US-ASCII"))
      encoding = null;
    OutputDirectory.Stream stream = od.open(sourceUri, encoding);
    this.cr = stream.getCharRepertoire();
    this.pp = new StreamingPrettyprinter(od.getLineLength(), od.getLineSeparator(), stream.getWriter());
    this.nsb = nsb;
    char[] tem = new char[od.getIndent()];
    for (int i = 0; i < tem.length; i++)
      tem[i] = ' ';
    this.indent = new String(tem);
  }

  private void topLevel(Pattern p) {
    pp.text("<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\n");
    pp.text("<html xmlns='http://www.w3.org/1999/xhtml'>\n<head>\n");
    pp.text("<title>HTML5 schema</title>\n");
    pp.text("<style>\n");
    pp.text("body {\nbackground-color: #eee;\n}\n");
    pp.text(".comment {\ndisplay: block;\n}\n");
    pp.text("#schema > .chunk {\nbackground-color: lightyellow;\nmargin-top: 20px;\nmargin-left: 20px;\nmargin-bottom: 20px;\n}\n");
    pp.text("#schema > .define {\nbackground-color: lightyellow;\n}\n");
    pp.text(".chunk {\nmargin-left: 20px;\nbackground-color: beige;\nmargin: 6px;\nborder: 1px dotted gray;\npadding: 6px;\n}\n");
    pp.text(".namespaces, .datatypes {\nmargin-left: 20px;\nbackground-color: lightyellow;\nmargin: 6px;\nborder: 1px dotted gray;\npadding: 6px;\n}\n");
    pp.text(".define {\nbackground-color: white;\nmargin: 6px;\nborder: 1px dotted gray;\npadding: 6px;\n}\n");
    pp.text(".comment, .annotation {\ncolor: purple;\n}\n");
    pp.text(".type {\ncolor: orangered;\n}\n");
    pp.text(".pattern {\npadding-left: 2px;\n}\n");
    pp.text(".patternname {\ncolor: #999;\n}\n");
    pp.text(".patternname > a {\ncolor: #999;\ntext-decoration: none;\nmargin: 0px 2px 0px 2px;\npadding: 1px 1px 1px 1px;\n}\n");
    pp.text(".patternname > a:hover {\nbackground-color: #0b5b9d;\ncolor: white;\nborder: 1px dotted #000;\npadding: 1px 2px 1px 2px;\nmargin: 0px;\n}\n");
    pp.text(".patternname > a:active {\nbackground-color: #0b5b9d;\ncolor: white;\nposition: relative;\ntop: 1px;\nleft: 1px;\npadding: 1px 2px 1px 2px;\n margin: 0px;\n}\n");
    pp.text(".name {\ncolor: green;\nfont-weight: bold;\n}\n");
    pp.text("</style>\n");
    pp.text("</head>\n");
    pp.text("<body>\n");
    pp.text("<div id='schema'>\n");
    p.accept(new TextAnnotationMerger());
    boolean implicitGrammar = p instanceof GrammarPattern && p.getAttributeAnnotations().isEmpty();
    pp.text("<!-- \n");
    outputNamespaceDeclarations();
    outputDatatypeLibraryDeclarations(p);
    pp.text(" -->\n");
    if (implicitGrammar && !p.getLeadingComments().isEmpty()) {
      leadingComments(p);
      pp.hardNewline();
    }
    if (implicitGrammar) {
      for (AnnotationChild annotationChild : p.getChildElementAnnotations()) {
        annotationChild.accept(annotationChildOutput);
        pp.hardNewline();
      }
      innerBody(((GrammarPattern)p).getComponents());
      // This deals with trailing comments
      for (AnnotationChild annotationChild : p.getFollowingElementAnnotations()) {
        pp.hardNewline();
        annotationChild.accept(annotationChildOutput);
      }
    }
    else
      p.accept(patternOutput);
    outputNamespaceDeclarations();
    outputDatatypeLibraryDeclarations(p);
    pp.text("\n</div>\n");
    pp.text("\n</body>");
    pp.text("\n</html>");
    // The pretty printer ensures that we have a terminating newline.
    pp.close();
  }

  private void outputNamespaceDeclarations() {
    List<String> prefixes = new Vector<String>();
    prefixes.addAll(nsb.getPrefixes());
    Collections.sort(prefixes);

    boolean needNewline = false;

    String defaultPrefix = null;
    String defaultNamespace = nsb.getNamespaceUri("");
    if (defaultNamespace != null && !defaultNamespace.equals(SchemaBuilder.INHERIT_NS))
      defaultPrefix = nsb.getNonEmptyPrefix(defaultNamespace);
    for (String prefix : prefixes) {
      String ns = nsb.getNamespaceUri(prefix);
      if (prefix.length() == 0) {
        if (defaultPrefix == null && !ns.equals(SchemaBuilder.INHERIT_NS)) {
          pp.startGroup();
          pp.text("default namespace =");
          pp.startNest(indent);
          pp.softNewline(" ");
          literal(ns);
          pp.endNest();
          pp.endGroup();
          pp.hardNewline();
          needNewline = true;
        }
      }
      else if (!prefix.equals("xml") && !prefix.equals("local")
          && !ns.equals("http://relaxng.org/ns/compatibility/annotations/1.0")
          && !ns.equals("http://relaxng.org/ns/structure/1.0")) {
        pp.text("<div class='namespaces'>");
        pp.startGroup();
        if (prefix.equals(defaultPrefix))
          pp.text("default namespace ");
        else
          pp.text("namespace ");
        encodedText(prefix);
        pp.text(" =");
        pp.startNest(indent);
        pp.softNewline(" ");
        if (ns.equals(SchemaBuilder.INHERIT_NS))
          pp.text("inherit");
        else
          literal(ns);
        pp.endNest();
        pp.endGroup();
        pp.text("</span>");
        pp.hardNewline();
        needNewline = true;
      }
    }

    if (needNewline)
      pp.hardNewline();
  }


  private void outputDatatypeLibraryDeclarations(Pattern p) {
    datatypeLibraryMap.put(WellKnownNamespaces.XML_SCHEMA_DATATYPES, "xsd");
    List<String> datatypeLibraries = new Vector<String>();
    datatypeLibraries.addAll(DatatypeLibraryVisitor.findDatatypeLibraries(p));
    if (datatypeLibraries.isEmpty())
      return;
    Collections.sort(datatypeLibraries);
    for (int i = 0, len = datatypeLibraries.size(); i < len; i++) {
      String prefix = "d";
      if (len > 1)
        prefix += Integer.toString(i + 1);
      String uri = datatypeLibraries.get(i);
      datatypeLibraryMap.put(uri, prefix);
      pp.hardNewline();
      pp.text("<div class='datatypes'>");
      pp.startGroup();
      pp.text("datatypes ");
      encodedText(prefix);
      pp.text(" =");
      pp.startNest(indent);
      pp.softNewline(" ");
      literal(uri);
      pp.endNest();
      pp.endGroup();
      pp.text("</div>");
    }
  }

  private static class TextAnnotationMerger extends VoidVisitor {
    public void voidVisitElement(ElementAnnotation ea) {
      TextAnnotation prevText = null;
      for (Iterator<AnnotationChild> iter = ea.getChildren().iterator(); iter.hasNext();) {
        AnnotationChild child = iter.next();
        if (child instanceof TextAnnotation) {
          if (prevText == null)
            prevText = (TextAnnotation)child;
          else {
            prevText.setValue(prevText.getValue() + ((TextAnnotation)child).getValue());
            iter.remove();
          }
        }
        else {
          prevText = null;
          child.accept(this);
        }
      }
    }
  }

  static class DatatypeLibraryVisitor extends VoidVisitor {
    private final Set<String> datatypeLibraries = new HashSet<String>();

    public void voidVisitValue(ValuePattern p) {
      noteDatatypeLibrary(p.getDatatypeLibrary());
      super.voidVisitValue(p);
    }

    public void voidVisitData(DataPattern p) {
      noteDatatypeLibrary(p.getDatatypeLibrary());
      super.voidVisitData(p);
    }

    private void noteDatatypeLibrary(String uri) {
      if (!uri.equals("") && !uri.equals(WellKnownNamespaces.XML_SCHEMA_DATATYPES))
        datatypeLibraries.add(uri);
    }

    static Set<String> findDatatypeLibraries(Pattern p) {
      DatatypeLibraryVisitor dlv = new DatatypeLibraryVisitor();
      p.accept(dlv);
      return dlv.datatypeLibraries;
    }
  }

  static class NamespaceVisitor extends VoidVisitor {
    private final NamespaceManager nsm = new NamespaceManager();
    private boolean isAttribute;

    public void voidVisitInclude(IncludeComponent c) {
      super.voidVisitInclude(c);
      nsm.requireNamespace(c.getNs(), true);
    }

    public void voidVisitExternalRef(ExternalRefPattern p) {
      super.voidVisitExternalRef(p);
      nsm.requireNamespace(p.getNs(), true);
    }

    public void voidVisitElement(ElementPattern p) {
      isAttribute = false;
      super.voidVisitElement(p);
    }

    public void voidVisitAttribute(AttributePattern p) {
      isAttribute = true;
      super.voidVisitAttribute(p);
    }

    public void voidVisitName(NameNameClass nc) {
      super.voidVisitName(nc);
      if (!isAttribute || nc.getNamespaceUri().length() != 0)
        nsm.requireNamespace(nc.getNamespaceUri(), !isAttribute);
      if (nc.getPrefix() == null) {
        if (!isAttribute)
          nsm.preferBinding("", nc.getNamespaceUri());
      }
      else
        nsm.preferBinding(nc.getPrefix(), nc.getNamespaceUri());
    }

    public void voidVisitNsName(NsNameNameClass nc) {
      super.voidVisitNsName(nc);
      nsm.requireNamespace(nc.getNs(), false);
    }

    public void voidVisitValue(ValuePattern p) {
      super.voidVisitValue(p);
      for (Map.Entry<String, String> entry : p.getPrefixMap().entrySet()) {
        nsm.requireBinding(entry.getKey(), entry.getValue());
      }
    }

    public void voidVisitElement(ElementAnnotation ea) {
      super.voidVisitElement(ea);
      noteAnnotationBinding(ea.getPrefix(), ea.getNamespaceUri());
      noteContext(ea.getContext(), true);
    }

    private void noteContext(NamespaceContext context, boolean required) {
      if (context == null)
        return;
      for (String prefix : context.getPrefixes()) {
        // Default namespace is not relevant to annotations
        if (!prefix.equals("")) {
          String ns = context.getNamespace(prefix);
          if (ns != null && !ns.equals(SchemaBuilder.INHERIT_NS)) {
            if (required)
              nsm.requireBinding(prefix, ns);
            else
              nsm.preferBinding(prefix, ns);
          }
        }
      }
    }

    public void voidVisitAttribute(AttributeAnnotation a) {
      super.voidVisitAttribute(a);
      noteAnnotationBinding(a.getPrefix(), a.getNamespaceUri());
    }

    private void noteAnnotationBinding(String prefix, String ns) {
      if (ns.length() != 0)
        nsm.requireNamespace(ns, false);
      if (prefix != null)
        nsm.preferBinding(prefix, ns);
    }

    public void voidVisitAnnotated(Annotated p) {
      p.leadingCommentsAccept(this);
      noteContext(p.getContext(), !p.getAttributeAnnotations().isEmpty());
      p.attributeAnnotationsAccept(this);
      List<AnnotationChild> before = (p.mayContainText()
                     ? p.getFollowingElementAnnotations()
                     : p.getChildElementAnnotations());
      // Avoid unnecessary prefix for documentation
      int state = 0;
      for (AnnotationChild child : before) {
        if (state < 2 && documentationString(child) != null)
          state = 1;
        else if (state != 1 || !(child instanceof Comment))
          state = 2;
        if (state == 2)
          child.accept(this);
      }
      if (!p.mayContainText())
        p.followingElementAnnotationsAccept(this);
    }

    static NamespaceManager.NamespaceBindings createBindings(Pattern p) {
      NamespaceVisitor nsv = new NamespaceVisitor();
      p.accept(nsv);
      return nsv.nsm.createBindings();
    }
  }

  private class ComponentOutput implements ComponentVisitor<VoidValue> {
    public VoidValue visitDefine(DefineComponent c) {
      String uname = c.getName();
      String name = c.getName();
      if (name.endsWith(".elem"))
        name = name.substring(0,name.length()-5);
      if (!c.getName().startsWith("common") && name.indexOf(".attrs.") != -1) {
        if (!c.getName().startsWith("script.attrs.embedded")
            && !c.getName().startsWith("script.attrs.imported")
            && !c.getName().startsWith("embed.attrs.other")
            && !c.getName().startsWith("media.attrs.src")
            )
          name = name.substring(name.indexOf(".attrs.")+7);
      }
      if (c.getName().startsWith("common.data.")) {
        name = name.substring(12);
      }
      if (c.getName().startsWith("form.data.")) {
        name = name.substring(10);
      }
      if (c.getName().startsWith("scripting.attr.")) {
        name = name.substring(name.indexOf(".attr.")+6);
      }
      if (c.getName().startsWith("aria.prop")) {
        name = "aria-" + name.substring(10);
      }
      if (c.getName().startsWith("aria.state")) {
        name = "aria-" + name.substring(11);
      }
      if (c.getName().startsWith("common-form.attrs.")) {
        name = name.substring(18);
      }
      //if (c.getName().startsWith("area.attrs.shape.")) {
      //  name = "shape";
      //}
      //if (c.getName().startsWith("area.attrs.coords.")) {
      //  name = "coords";
      //}
      pp.text("<div class='define'");
      pp.text(" id='");
      if (name == DefineComponent.START)
        pp.text("start");
      else
        if (uname.indexOf(".attrs.") != -1
            || uname.indexOf("scripting.attr.") != -1
            || uname.startsWith("common.data.")
            || uname.startsWith("form.data.")
            ) {
          identifier(uname);
        } else { 
          identifier(name);
        }
      pp.text("-define'>");
      pp.hardNewline();
      startAnnotations(c);
      pp.startGroup();
      pp.text("  <div class='patternname'");
      pp.text(" id='the-");
      if (name == DefineComponent.START)
        pp.text("start");
      else
        if (uname.indexOf(".attrs.") != -1
            || uname.indexOf("scripting.attr.") != -1
            || uname.startsWith("common.data.")
            || uname.startsWith("form.data.")
            ) {
          identifier(uname);
        } else {
          identifier(name);
        }
      pp.text("'>");
      pp.text("<a href='#the-");
      if (name == DefineComponent.START)
        pp.text("start");
      else
        if (uname.indexOf(".attrs.") != -1
            || uname.indexOf("scripting.attr.") != -1
            || uname.startsWith("common.data.")
            || uname.startsWith("form.data.")
            ) {
          identifier(uname);
        } else { 
          identifier(name);
        }
      pp.text("'>");
      if (name == DefineComponent.START)
        pp.text("start");
      else
        identifier(name);
      pp.text("</a>");
      Combine combine = c.getCombine();
      String op;
      if (combine == null)
        op = " =";
      else if (combine == Combine.CHOICE)
        op = " |=";
      else
        op = " &amp;=";
      pp.text(op);
      pp.text("</div>");
      pp.softNewline(" ");
      pp.startNest("  ");
      pp.text("  <span");
      pp.text(" class='pattern'");
      pp.text(" id='");
      if (name == DefineComponent.START)
        pp.text("start");
      else
        if (uname.indexOf(".attrs.") != -1
            || uname.indexOf("scripting.attr.") != -1
            || uname.startsWith("common.data.")
            || uname.startsWith("form.data.")
            ) {
          identifier(uname);
        } else {
          identifier(name);
        }
      pp.text("'>");
      c.getBody().accept(noParenPatternOutput);
      pp.text("</span>");
      pp.endNest();
      pp.endGroup();
      endAnnotations(c);
      pp.hardNewline();
      pp.text("</div>");
      return VoidValue.VOID;
    }

    public VoidValue visitDiv(DivComponent c) {
      pp.text("<div class='chunk'>\n");
      startAnnotations(c);
      innerBody(c.getComponents());
      endAnnotations(c);
      pp.text("\n</div>");
      return VoidValue.VOID;
    }

    public VoidValue visitInclude(IncludeComponent c) {
      startAnnotations(c);
      pp.startGroup();
      pp.text("include ");
      pp.startNest("include ");
      literal(od.reference(sourceUri, c.getUri()));
      inherit(c.getNs());
      pp.endNest();
      pp.endGroup();
      List<Component> components = c.getComponents();
      if (!components.isEmpty())
        body(components);
      endAnnotations(c);
      return VoidValue.VOID;
    }
  }

  class PatternOutput implements PatternVisitor<VoidValue> {
    private final boolean alwaysUseParens;

    PatternOutput(boolean alwaysUseParens) {
      this.alwaysUseParens = alwaysUseParens;
    }

    public VoidValue visitGrammar(GrammarPattern p) {
      startAnnotations(p);
      pp.text("grammar");
      body(p);
      endAnnotations(p);
      return VoidValue.VOID;
    }

    public VoidValue visitElement(ElementPattern p) {
      isAttributeNameClass = false;
      nameClassed(p, "element ");
      return VoidValue.VOID;
    }

    public VoidValue visitAttribute(AttributePattern p) {
      isAttributeNameClass = true;
      nameClassed(p, "attribute ");
      return VoidValue.VOID;
    }

    private void nameClassed(NameClassedPattern p, String key) {
      startAnnotations(p);
      pp.text("<span class='type'>");
      pp.text(key);
      pp.text("</span>");
      pp.hardNewline();
      pp.startNest(key);
      pp.text("<span class='name'>");
      p.getNameClass().accept(noParenNameClassOutput);
      pp.text("</span>");
      pp.endNest();
      pp.hardNewline();
      pp.text(" {");
      pp.startNest(" {");
      pp.text("<span class='model'>");
      braceChild(p);
      pp.text("</span>");
      pp.text("}");
      pp.endNest();
      pp.hardNewline();
      endAnnotations(p);
    }

    private void braceChild(UnaryPattern p) {
      Pattern child = p.getChild();
      boolean isSimple = !complexityCache.isComplex(child);
      if (isSimple)
        pp.startGroup();
      pp.startNest(indent);
      if (isSimple)
        pp.softNewline(" ");
      else
        pp.hardNewline();
      child.accept(noParenPatternOutput);
      pp.endNest();
      if (isSimple)
        pp.softNewline(" ");
      else
        pp.hardNewline();
      if (isSimple)
        pp.endGroup();
    }

    public VoidValue visitOneOrMore(OneOrMorePattern p) {
      postfix(p, "<span class='postfix oneormore' title='ONE OR MORE'>+</span> ");
      return VoidValue.VOID;
    }

    public VoidValue visitZeroOrMore(ZeroOrMorePattern p) {
      postfix(p, "<span class='postfix zeroormore' title='ZERO OR MORE'>*</span> ");
      return VoidValue.VOID;
    }

    public VoidValue visitOptional(OptionalPattern p) {
      postfix(p, "<span class='postfix optional' title='OPTIONAL (ZERO OR ONE)'>?</span> ");
      return VoidValue.VOID;
    }

    private void postfix(UnaryPattern p, String op) {
      if (!startAnnotations(p)) {
        p.getChild().accept(patternOutput);
        pp.text(op);
      }
      else {
        pp.text(" <span class='agroupof'>");
        pp.startNest("<span class='agroupof'>");
        p.getChild().accept(patternOutput);
        pp.endNest();
        pp.text(op);
        pp.text("</span>");
      }
      endAnnotations(p);
    }

    public VoidValue visitRef(RefPattern p) {
      String uref = p.getName();
      String ref = p.getName();
      if (ref.endsWith(".elem"))
        ref = ref.substring(0,ref.length()-5);
      if (!p.getName().startsWith("common") && ref.indexOf(".attrs.") != -1) {
        if (!p.getName().startsWith("script.attrs.embedded") 
            && !p.getName().startsWith("script.attrs.imported")
            && !p.getName().startsWith("embed.attrs.other")
            && !p.getName().startsWith("media.attrs.src")
            )
          ref = ref.substring(ref.indexOf(".attrs.")+7);
      }
      if (p.getName().startsWith("common.data.")) {
        ref = ref.substring(12);
      }
      if (p.getName().startsWith("form.data.")) {
        ref = ref.substring(10);
      }
      if (p.getName().startsWith("common.attrs.")) {
        if (!p.getName().startsWith("common.attrs.basic")
            && !p.getName().startsWith("common.attrs.core")
            && !p.getName().startsWith("common.attrs.event-handler")
            && !p.getName().startsWith("common.attrs.xml")
            && !p.getName().startsWith("common.attrs.i18n")
            && !p.getName().startsWith("common.attrs.present")
            && !p.getName().startsWith("common.attrs.other")
            && !p.getName().startsWith("common.attrs.scripting")
            && !p.getName().startsWith("common.attrs.repetition")
            && !p.getName().startsWith("common.attrs.interact")
            && !p.getName().startsWith("common.attrs.interaction")
            && !p.getName().startsWith("common.attrs.language")
            && !p.getName().startsWith("common.attrs.aria")
            )
          ref = ref.substring(ref.indexOf(".attrs.")+7);
      }
      if (p.getName().startsWith("scripting.attr.")) {
        ref = ref.substring(ref.indexOf(".attr.")+6);
      }
      if (p.getName().startsWith("aria.prop")) {
        ref = "aria-" + ref.substring(10);
      }
      if (p.getName().startsWith("aria.state")) {
        ref = "aria-" + ref.substring(11);
      }
      if (p.getName().startsWith("common-form.attrs.")) {
        ref = ref.substring(18);
      }
      //if (p.getName().startsWith("area.attrs.shape.")) {
      //  ref = "shape";
      //}
      //if (p.getName().startsWith("area.attrs.coords.")) {
      //  ref = "coords";
      //}
      startAnnotations(p);
      if (p.getName().startsWith("aria.role.")) {
        pp.text("<span class='attribute-name'>role</span>=");
        pp.text("\"<code>"+ref.substring(10)+"</code>\"");
      } else {
        pp.text("<a class='ref' href='#");
        if (uref.indexOf(".attrs.") != -1
            || uref.indexOf("scripting.attr.") != -1
            || uref.startsWith("common.data.")
            || uref.startsWith("form.data.")
            ) {
          identifier(uref);
          pp.text("' title='");
          identifier(uref);
        } else { 
          identifier(ref);
        }
        pp.text("'>");
        identifier(ref);
        pp.text("</a>");
      }
      endAnnotations(p);
      return VoidValue.VOID;
    }

    public VoidValue visitParentRef(ParentRefPattern p) {
      startAnnotations(p);
      pp.text("parent ");
      identifier(p.getName());
      endAnnotations(p);
      return VoidValue.VOID;
    }

    public VoidValue visitExternalRef(ExternalRefPattern p) {
      startAnnotations(p);
      pp.startGroup();
      pp.text("external ");
      pp.startNest("external ");
      literal(od.reference(sourceUri, p.getUri()));
      inherit(p.getNs());
      pp.endNest();
      pp.endGroup();
      endAnnotations(p);
      return VoidValue.VOID;
    }

    public VoidValue visitText(TextPattern p) {
      startAnnotations(p);
      pp.text("<a class='ref' href='#normal-character-data'>normal-character-data</a>");
      endAnnotations(p);
      return VoidValue.VOID;
    }

    public VoidValue visitEmpty(EmptyPattern p) {
      startAnnotations(p);
      pp.text("empty");
      endAnnotations(p);
      return VoidValue.VOID;
    }

    public VoidValue visitNotAllowed(NotAllowedPattern p) {
      startAnnotations(p);
      pp.text("notAllowed");
      endAnnotations(p);
      return VoidValue.VOID;
    }

    public VoidValue visitList(ListPattern p) {
      prefix(p, "list");
      return VoidValue.VOID;
    }

    public VoidValue visitMixed(MixedPattern p) {
      prefix(p, "mixed");
      return VoidValue.VOID;
    }

    private void prefix(UnaryPattern p, String key) {
      startAnnotations(p);
      pp.text(key);
      pp.text("{");
      braceChild(p);
      pp.text("}");
      endAnnotations(p);
    }

    public VoidValue visitChoice(ChoicePattern p) {
      composite(p, " <span class='postfix or'>or</span> ", false);
      return VoidValue.VOID;
    }

    public VoidValue visitInterleave(InterleavePattern p) {
      composite(p, " <span class='postfix intermixed'>intermixed with</span> ", false);
      return VoidValue.VOID;
    }

    public VoidValue visitGroup(GroupPattern p) {
      composite(p, " <span class='postfix followedby'>followed by</span> ", true);
      return VoidValue.VOID;
    }

    void composite(CompositePattern p, String sep, boolean sepBeforeNewline) {
      boolean useParens = alwaysUseParens;
      if (startAnnotations(p))
        useParens = true;
      boolean isSimple = !complexityCache.isComplex(p);
      if (isSimple)
        pp.startGroup();
      if (useParens) {
        pp.text(" <span class='agroupof'>");
        pp.startNest("<span class='agroupof'>");
      }

      boolean first = true;
      for (Pattern child : p.getChildren()) {
        if (!first) {
          if (sepBeforeNewline)
            pp.text(sep);
          if (isSimple)
            pp.softNewline(" ");
          else
            pp.hardNewline();
          if (!sepBeforeNewline) {
            pp.text(sep);
            pp.startNest(sep);
          }
        }
        child.accept(patternOutput);
        if (first)
          first = false;
        else if (!sepBeforeNewline)
          pp.endNest();
      }
      if (useParens) {
        pp.endNest();
        pp.text("</span>");
      }
      if (isSimple)
        pp.endGroup();
      endAnnotations(p);
    }

    public VoidValue visitData(DataPattern p) {
      startAnnotations(p);
      String lib = p.getDatatypeLibrary();
      String qn;
      if (!lib.equals(""))
        qn = datatypeLibraryMap.get(lib) + ":" + p.getType();
      else
        qn = p.getType();
      qn = encode(qn);
      pp.text(qn);
      List<Param> params = p.getParams();
      if (params.size() > 0) {
        pp.startGroup();
        pp.text(" {");
        pp.startNest(indent);
        for (Param param : params) {
          pp.softNewline(" ");
          startAnnotations(param);
          pp.startGroup();
          encodedText(param.getName());
          pp.text(" =");
          pp.startNest(indent);
          pp.softNewline(" ");
          literal(param.getValue());
          pp.endNest();
          pp.endGroup();
          endAnnotations(param);
        }
        pp.endNest();
        pp.softNewline(" ");
        pp.text("}");
        pp.endGroup();
      }
      Pattern e = p.getExcept();
      if (e != null) {
        boolean useParen = (!e.mayContainText()
                            && !e.getFollowingElementAnnotations().isEmpty());
        String s;
        if (params.isEmpty())
          s = " - ";
        else {
          pp.startGroup();
          pp.softNewline(" ");
          s = "- ";
        }
        if (useParen)
          s += "(";
        pp.text(s);
        pp.startNest(params.isEmpty() ? qn + s : s);
        e.accept(useParen ? noParenPatternOutput : patternOutput);
        pp.endNest();
        if (useParen)
          pp.text(")");
        if (!params.isEmpty())
          pp.endGroup();
      }
      endAnnotations(p);
      return VoidValue.VOID;
    }

    public VoidValue visitValue(ValuePattern p) {
      for (Map.Entry<String, String> entry : p.getPrefixMap().entrySet()) {
        String prefix = entry.getKey();
        String uri = entry.getValue();
        if (!uri.equals(nsb.getNamespaceUri(prefix))) {
          if (prefix.equals(""))
            er.error("value_inconsistent_default_binding", uri, p.getSourceLocation());
          else
            er.error("value_inconsistent_binding", prefix, uri, p.getSourceLocation());
        }
      }
      startAnnotations(p);
      String lib = p.getDatatypeLibrary();
      pp.startGroup();
      String str = null;
      if (lib.equals("")) {
        if (!p.getType().equals("token"))
          str = p.getType() + " ";
      }
      else
        str = datatypeLibraryMap.get(lib) + ":" + p.getType() + " ";
      if (str != null) {
        String encoded = encode(str);
        pp.text(encoded);
        pp.startNest(encoded);
      }
      literal(p.getValue());
      if (str != null)
        pp.endNest();
      pp.endGroup();
      endAnnotations(p);
      return VoidValue.VOID;
    }

  }

  class NameClassOutput implements NameClassVisitor<VoidValue> {
    private final boolean alwaysUseParens;

    NameClassOutput(boolean alwaysUseParens) {
      this.alwaysUseParens = alwaysUseParens;
    }

    public VoidValue visitAnyName(AnyNameNameClass nc) {
      NameClass e = nc.getExcept();
      if (e == null) {
        startAnnotations(nc);
        pp.text("*");
      }
      else {
        boolean useParens = startAnnotations(nc) || alwaysUseParens;
        String s = useParens ?  "(* - " : "* - ";
        pp.text(s);
        pp.startNest(s);
        e.accept(nameClassOutput);
        if (useParens)
          pp.text(")");
        pp.endNest();
      }
      endAnnotations(nc);
      return VoidValue.VOID;
    }

    public VoidValue visitNsName(NsNameNameClass nc) {
      NameClass e = nc.getExcept();
      String prefix = nsb.getNonEmptyPrefix(nc.getNs());
      if (e == null) {
        startAnnotations(nc);
        encodedText(prefix);
        pp.text(":*");
      }
      else {
        boolean useParens = startAnnotations(nc) || alwaysUseParens;
        String s = useParens ? "(" : "";
        s += encode(prefix);
        s += ":* - ";
        pp.text(s);
        pp.startNest(s);
        e.accept(nameClassOutput);
        pp.endNest();
        if (useParens)
          pp.text(")");
      }
      endAnnotations(nc);
      return VoidValue.VOID;
    }

    public VoidValue visitName(NameNameClass nc) {
      startAnnotations(nc);
      qualifiedName(nc.getNamespaceUri(), nc.getPrefix(), nc.getLocalName(), isAttributeNameClass);
      endAnnotations(nc);
      return VoidValue.VOID;
    }

    public VoidValue visitChoice(ChoiceNameClass nc) {
      boolean useParens = alwaysUseParens;
      if (startAnnotations(nc))
        useParens = true;
      else if (nc.getChildren().size() == 1)
        useParens = false;
      if (useParens) {
        pp.text(" <span class='agroupof'>");
        pp.startNest("<span class='agroupof'>");
      }
      pp.startGroup();
      boolean first = true;
      for (NameClass child : nc.getChildren()) {
        if (first)
          first = false;
        else {
          pp.softNewline(" ");
          pp.text("| ");
        }
        child.accept(nameClassOutput);
      }
      pp.endGroup();
      if (useParens) {
        pp.endNest();
        pp.text("</span>");
      }
      endAnnotations(nc);
      return VoidValue.VOID;
    }
  }

  class AnnotationChildOutput implements AnnotationChildVisitor<VoidValue> {
    public VoidValue visitText(TextAnnotation ta) {
      literal(ta.getValue());
      return VoidValue.VOID;
    }

    public VoidValue visitComment(Comment c) {
      comment("#", c.getValue());
      return VoidValue.VOID;
    }

    public VoidValue visitElement(ElementAnnotation elem) {
      checkContext(elem.getContext(), elem.getSourceLocation());
      pp.text("<span class='annotation'>## ");
      qualifiedName(elem.getNamespaceUri(), elem.getPrefix(), elem.getLocalName(),
                    // unqualified annotation element names have "" namespace
                    true);
      pp.text(" ");
      annotationBody(elem.getAttributes(), elem.getChildren());
      pp.text("</span>\n");
      return VoidValue.VOID;
    }
  }

  class FollowingAnnotationChildOutput extends AnnotationChildOutput {
    public VoidValue visitElement(ElementAnnotation elem) {
      pp.text(">> ");
      pp.startNest(">> ");
      super.visitElement(elem);
      pp.endNest();
      return VoidValue.VOID;
    }
  }

  private static boolean hasAnnotations(Annotated annotated) {
    return (!annotated.getChildElementAnnotations().isEmpty()
            || !annotated.getAttributeAnnotations().isEmpty()
            || !annotated.getFollowingElementAnnotations().isEmpty());
  }

  private boolean startAnnotations(Annotated annotated) {
    if (!annotated.getLeadingComments().isEmpty()) {
      leadingComments(annotated);
      if (!hasAnnotations(annotated))
        return false;
    }
    else if (!hasAnnotations(annotated))
      return false;
    List<AnnotationChild> before = (annotated.mayContainText()
                                    ? annotated.getFollowingElementAnnotations()
                                    : annotated.getChildElementAnnotations());
    int i = 0;
    int len = before.size();
    for (; i < len; i++) {
      int j = i;
      if (i != 0) {
        do {
          if (!(before.get(j) instanceof Comment))
            break;
        } while (++j < len);
        if (j >= len)
          break;
      }
      String doc = documentationString(before.get(j));
      if (doc == null)
        break;
      if (j == i)
        pp.hardNewline();
      else {
        for (;;) {
          before.get(i).accept(annotationChildOutput);
          if (++i == j)
            break;
          pp.hardNewline();
        }
      }
      comment("##", doc);
    }
    if (i > 0)
      before = before.subList(i, len);
    pp.startGroup();
    if (!annotated.getAttributeAnnotations().isEmpty()
        || !before.isEmpty()) {
      if (!annotated.getAttributeAnnotations().isEmpty())
        checkContext(annotated.getContext(), annotated.getSourceLocation());
      annotationBody(annotated.getAttributeAnnotations(), before);
      pp.softNewline(" ");
    }
    return true;
  }

  private static String documentationString(AnnotationChild child) {
    if (!(child instanceof ElementAnnotation))
     return null;
    ElementAnnotation elem = (ElementAnnotation)child;
    if (!elem.getLocalName().equals("documentation"))
      return null;
    if (!elem.getNamespaceUri().equals(WellKnownNamespaces.RELAX_NG_COMPATIBILITY_ANNOTATIONS))
      return null;
    if (!elem.getAttributes().isEmpty())
      return null;
    StringBuffer buf = new StringBuffer();
    for (AnnotationChild a : elem.getChildren()) {
      if (!(a instanceof TextAnnotation))
        return null;
      buf.append(((TextAnnotation)a).getValue());
    }
    return buf.toString();
  }

  private void endAnnotations(Annotated annotated) {
    if (!annotated.mayContainText()) {
      for (AnnotationChild child : annotated.getFollowingElementAnnotations()) {
        if (annotated instanceof Component)
          pp.hardNewline();
        else
          pp.softNewline(" ");
        AnnotationChildVisitor<VoidValue> output = (annotated instanceof Component
                                                    ? annotationChildOutput
                                                    : followingAnnotationChildOutput);
        child.accept(output);
      }
    }
    if (hasAnnotations(annotated))
      pp.endGroup();
  }

  private void leadingComments(Annotated annotated) {
    boolean first = true;
    for (Comment comment : annotated.getLeadingComments()) {
      if (!first)
        pp.hardNewline();
      else
        first = false;
      comment.accept(annotationChildOutput);
    }
  }

  private void annotationBody(List<AttributeAnnotation> attributes, List<AnnotationChild> children) {
    pp.startGroup();
    pp.startNest(indent);
    for (AnnotationChild child : children) {
      child.accept(annotationChildOutput);
    }
    pp.endNest();
    pp.endGroup();
  }

  private void body(Container container) {
    body(container.getComponents());
  }

  private void body(List<Component> components) {
    if (components.size() == 0)
      pp.text(" { }");
    else {
      pp.text(" {");
      pp.startNest(indent);
      pp.hardNewline();
      innerBody(components);
      pp.endNest();
      pp.hardNewline();
      pp.text("}");
    }
  }

  private void innerBody(List<Component> components) {
    boolean first = true;
    for (Component c : components) {
      if (first)
        first = false;
      else
        pp.hardNewline();
      c.accept(componentOutput);
    }
  }

  private void inherit(String ns) {
    if (ns.equals(nsb.getNamespaceUri("")))
      return;
    pp.softNewline(" ");
    pp.text("inherit = ");
    encodedText(nsb.getNonEmptyPrefix(ns));
  }

  private void identifier(String name) {
    //if (keywordSet.contains(name))
      //pp.text("\\");
    encodedText(name);
  }

  private static final String[] delims = { "\"", "'", "\"\"\"", "'''" };

  private void literal(String str) {
    for (int i = 0, len = str.length();;) {
      // Find the delimiter that gives the longest segment
      String bestDelim = null;
      int bestEnd = -1;
      int lim = str.indexOf('\n', i);
      if (lim < 0)
        lim = len;
      else
        ++lim;
      for (int j = 0; j < delims.length; j++) {
        int end = (str + delims[j]).indexOf(delims[j], i);
        if (end > bestEnd) {
          bestDelim = delims[j];
          bestEnd = end;
          if (end >= lim) {
            bestEnd = lim;
            break;
          }
        }
      }
      if (i != 0) {
        pp.text(" ~");
        pp.softNewline(" ");
      }
      pp.text(bestDelim);
      encodedText(str.substring(i, bestEnd));
      pp.text(bestDelim);
      i = bestEnd;
      if (i == len)
        break;
    }
  }

  private void encodedText(String str) {
    String escaped = str;
    int idx = escaped.lastIndexOf("&"); 
    if ( idx != -1 ) { 
      StringBuffer ret_amp = new StringBuffer(str); 
      ret_amp.replace(idx, idx+1, " <span class='postfix intermixed'>intermixed with</span> "); 
      while( (idx=str.lastIndexOf("&", idx-1)) != -1 ) { 
        ret_amp.replace(idx, idx+1, " <span class='postfix intermixed'>intermixed with</span> "); 
      } 
      escaped = ret_amp.toString(); 
    } 
    idx = escaped.lastIndexOf("<"); 
    if ( idx != -1 ) { 
      StringBuffer ret_lt = new StringBuffer(escaped); 
      ret_lt.replace(idx, idx+1, "&lt;"); 
      while( (idx=escaped.lastIndexOf("<", idx-1)) != -1 ) { 
        ret_lt.replace(idx, idx+1, "&lt;"); 
      } 
      escaped = ret_lt.toString(); 
    } 
    pp.text(encode(escaped));
  }

  private String encode(String str) {
    int start = 0;
    int len = str.length();
    for (int i = 0; i < len; i++) {
      char c = str.charAt(i);
      switch (c) {
      case '\\':
        if (!startsWithEscapeOpen(str, i))
          break;
        // fall through
      case '\r':
      case '\n':
        if (start < i)
          encodeBuf.append(str.substring(start, i));
        escape(c);
        start = i + 1;
        break;
      default:
        if (Utf16.isSurrogate(c)) {
          if (!cr.contains(c, str.charAt(i + 1))) {
            if (start < i)
              encodeBuf.append(str.substring(start, i));
            escape(Utf16.scalarValue(c, str.charAt(i + 1)));
            start = i + 2;
          }
          ++i;
        }
        else if (!cr.contains(c)) {
          if (start < i)
            encodeBuf.append(str.substring(start, i));
          escape(c);
          start = i + 1;
        }
        break;
      }
    }
    if (start == 0)
      return str;
    if (start != len)
      encodeBuf.append(str.substring(start, len));
    str = encodeBuf.toString();
    encodeBuf.setLength(0);
    return str;
  }

  private void escape(int n) {
    encodeBuf.append("\\x{");
    encodeBuf.append(Integer.toHexString(n));
    encodeBuf.append("}");
  }

  static private boolean startsWithEscapeOpen(String str, int off) {
    if (!str.startsWith("\\x", off))
      return false;
    for (off += 2; str.startsWith("x", off); off++)
      ;
    return str.startsWith("{", off);
  }

  /**
   * null means no prefix
   */
  private void qualifiedName(String ns, String prefix, String localName, boolean isAttribute) {
    prefix = choosePrefix(ns, prefix, isAttribute);
    if (prefix == null)
      encodedText(localName);
    else {
      encodedText(prefix);
      pp.text(":");
      encodedText(localName);
    }
  }

  /**
   * null means no prefix
   */
  private String choosePrefix(String ns, String prefix, boolean isAttribute) {
    if (prefix != null && ns.equals(nsb.getNamespaceUri(prefix)))
      return prefix;
    if (isAttribute) {
      if (ns.length() == 0)
        return null;
    }
    else {
      if (ns.equals(nsb.getNamespaceUri("")))
        return null;
    }
    return nsb.getNonEmptyPrefix(ns);
  }

  private void comment(String delim, String value) {
    int i = 0;
    for (;;) {
      pp.text("<span class='comment'>");
      pp.text(delim);
      if (i < value.length() && value.charAt(i) != '\t')
        pp.text(" ");
      int j = value.indexOf('\n', i);
      String tem = j < 0 ? value.substring(i) : value.substring(i, j);
      encodedText(tem);
      pp.text("</span>");
      pp.hardNewline();
      if (j < 0)
        break;
      i = j + 1;
    }
  }

  private void checkContext(NamespaceContext context, SourceLocation loc) {
    if (context == null)
      return;
    for (String prefix : context.getPrefixes()) {
      // Default namespace is not relevant to annotations
      if (!prefix.equals("")) {
        String ns = context.getNamespace(prefix);
        if (ns != null && !ns.equals(SchemaBuilder.INHERIT_NS)
            && !nsb.getNamespaceUri(prefix).equals(ns))
          er.warning("annotation_inconsistent_binding", prefix, ns, loc);
      }
    }
  }
}
