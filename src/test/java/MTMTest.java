import javax.inject.Inject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.io.File;

import org.daisy.maven.xproc.xprocspec.XProcSpecRunner;

import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.CSSStyledText;
import static org.daisy.pipeline.braille.common.Query.util.query;
import org.daisy.pipeline.braille.dotify.DotifyTranslator;

import static org.daisy.pipeline.pax.exam.Options.brailleModule;
import static org.daisy.pipeline.pax.exam.Options.calabashConfigFile;
import static org.daisy.pipeline.pax.exam.Options.domTraversalPackage;
import static org.daisy.pipeline.pax.exam.Options.felixDeclarativeServices;
import static org.daisy.pipeline.pax.exam.Options.logbackClassic;
import static org.daisy.pipeline.pax.exam.Options.logbackConfigFile;
import static org.daisy.pipeline.pax.exam.Options.mavenBundle;
import static org.daisy.pipeline.pax.exam.Options.mavenBundlesWithDependencies;
import static org.daisy.pipeline.pax.exam.Options.pipelineModule;
import static org.daisy.pipeline.pax.exam.Options.thisBundle;
import static org.daisy.pipeline.pax.exam.Options.xprocspec;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import org.junit.Test;
import org.junit.runner.RunWith;

import org.ops4j.pax.exam.Configuration;
import org.ops4j.pax.exam.junit.PaxExam;
import org.ops4j.pax.exam.Option;
import org.ops4j.pax.exam.spi.reactors.ExamReactorStrategy;
import org.ops4j.pax.exam.spi.reactors.PerClass;
import org.ops4j.pax.exam.util.PathUtils;

import static org.ops4j.pax.exam.CoreOptions.junitBundles;
import static org.ops4j.pax.exam.CoreOptions.options;

@RunWith(PaxExam.class)
@ExamReactorStrategy(PerClass.class)
public class MTMTest {
	
	@Inject
	private DotifyTranslator.Provider provider;
	
	@Test
	public void testTranslation() {
		BrailleTranslator.FromStyledTextToBraille translator = provider.get(query("(locale:sv_SE)")).iterator().next().fromStyledTextToBraille();
		assertEquals(braille("⠠⠙⠑⠞ ⠜⠗ ⠥⠝⠙⠑⠗ ⠍⠕⠗⠛⠕⠝⠍⠪⠞⠑⠞ ⠙⠑⠞ ⠓⠜⠝⠙⠑⠗⠄ ⠠⠍⠁⠗⠊⠁ ⠓⠡⠇⠇⠑⠗ ⠚⠥⠎⠞ ⠏⠡ ⠁⠞⠞ ⠇⠜⠎⠁ ⠥⠏⠏ ⠑⠝ ⠗⠁⠏⠏⠕⠗⠞⠄"),
		             translator.transform(styledText("Det är under morgonmötet det händer. Maria håller just på att läsa upp en rapport.","")));
	}
	
	@Inject
	private XProcSpecRunner xprocspecRunner;
	
	@Test
	public void runXProcSpec() throws Exception {
		File baseDir = new File(PathUtils.getBaseDir());
		boolean success = xprocspecRunner.run(new File(baseDir, "src/test/xprocspec"),
		                                      new File(baseDir, "target/xprocspec-reports"),
		                                      new File(baseDir, "target/surefire-reports"),
		                                      new File(baseDir, "target/xprocspec"),
		                                      new XProcSpecRunner.Reporter.DefaultReporter());
		assertTrue("XProcSpec tests should run with success", success);
	}
	
	@Configuration
	public Option[] config() {
		return options(
			logbackConfigFile(),
			calabashConfigFile(),
			domTraversalPackage(),
			felixDeclarativeServices(),
			thisBundle(),
			junitBundles(),
			mavenBundlesWithDependencies(
				brailleModule("common-utils"),
				brailleModule("css-utils"),
				brailleModule("dotify-utils"),
				brailleModule("dotify-formatter"),
				brailleModule("pef-utils"),
				brailleModule("dtbook-to-pef"),
				pipelineModule("file-utils"),
				mavenBundle("org.daisy.dotify:dotify.translator.impl:?"),
				mavenBundle("org.daisy.dotify:dotify.hyphenator.impl:?"),
				mavenBundle("org.daisy.dotify:dotify.text.impl:?"),
				// logging
				logbackClassic(),
				// xprocspec
				xprocspec(),
				mavenBundle("org.daisy.maven:xproc-engine-daisy-pipeline:?"))
		);
	}
	
	private Iterable<CSSStyledText> styledText(String... textAndStyle) {
		List<CSSStyledText> styledText = new ArrayList<CSSStyledText>();
		String text = null;
		boolean textSet = false;
		for (String s : textAndStyle) {
			if (textSet)
				styledText.add(new CSSStyledText(text, s));
			else
				text = s;
			textSet = !textSet; }
		if (textSet)
			throw new RuntimeException();
		return styledText;
	}
	
	private Iterable<String> braille(String... text) {
		return Arrays.asList(text);
	}
}
