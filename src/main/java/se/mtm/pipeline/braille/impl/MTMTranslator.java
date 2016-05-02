package se.mtm.pipeline.braille.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.net.URI;

import com.google.common.base.Objects;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

import org.daisy.pipeline.braille.common.AbstractBrailleTranslator;
import org.daisy.pipeline.braille.common.AbstractTransformProvider;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Function;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables.transform;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logCreate;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logSelect;
import org.daisy.pipeline.braille.common.BrailleTranslator;
import org.daisy.pipeline.braille.common.BrailleTranslatorProvider;
import org.daisy.pipeline.braille.common.CSSStyledText;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.Feature;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import org.daisy.pipeline.braille.common.TransformProvider;
import static org.daisy.pipeline.braille.common.TransformProvider.util.dispatch;
import static org.daisy.pipeline.braille.common.TransformProvider.util.memoize;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.dotify.DotifyTranslator;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.osgi.service.component.ComponentContext;

public interface MTMTranslator {
	
	@Component(
		name = "se.mtm.pipeline.braille.impl.MTMTranslator.Provider",
		service = {
			TransformProvider.class,
			BrailleTranslatorProvider.class
		}
	)
	public class Provider extends AbstractTransformProvider<BrailleTranslator> implements BrailleTranslatorProvider<BrailleTranslator> {
		
		private URI href;
		
		@Activate
		private void activate(ComponentContext context, final Map<?,?> properties) {
			href = asURI(context.getBundleContext().getBundle().getEntry("xml/block-translate.xpl"));
		}
		
		private final static Query translatorQuery = mutableQuery().add("locale", "sv_SE");
		
		private final static Iterable<BrailleTranslator> empty = Iterables.<BrailleTranslator>empty();
		
		private final static List<String> supportedInput = ImmutableList.of("css","text-css","dtbook","html");
		private final static List<String> supportedOutput = ImmutableList.of("css", "braille");
		
		/**
		 * Recognized features:
		 *
		 * - translator: Will only match if the value is `mtm'.
		 * - locale: Will only match if the language subtag is 'sv'.
		 *
		 */
		protected final Iterable<BrailleTranslator> _get(Query query) {
			final MutableQuery q = mutableQuery(query);
			for (Feature f : q.removeAll("input"))
				if (!supportedInput.contains(f.getValue().get()))
					return empty;
			for (Feature f : q.removeAll("output"))
				if (!supportedOutput.contains(f.getValue().get()))
					return empty;
			if (q.containsKey("locale"))
				if (!"sv".equals(parseLocale(q.removeOnly("locale").getValue().get()).getLanguage()))
					return empty;
			if (q.containsKey("translator"))
				if ("mtm".equals(q.removeOnly("translator").getValue().get()))
					if (q.isEmpty()) {
						return transform(
							logSelect(translatorQuery, dotifyTranslatorProvider),
							new Function<DotifyTranslator,BrailleTranslator>() {
								public BrailleTranslator _apply(DotifyTranslator translator) {
									return __apply(logCreate(new TransformImpl(translator))); }}); };
			return empty;
		}
		
		private class TransformImpl extends AbstractBrailleTranslator {
			
			private final FromStyledTextToBraille translator;
			private final XProc xproc;
			
			private TransformImpl(DotifyTranslator translator) {
				Map<String,String> options = ImmutableMap.of("query", mutableQuery().add("id", this.getIdentifier()).toString());
				xproc = new XProc(href, null, options);
				this.translator = translator.fromStyledTextToBraille();
			}
			
			@Override
			public XProc asXProc() {
				return xproc;
			}
			
			@Override
			public FromStyledTextToBraille fromStyledTextToBraille() {
				return fromStyledTextToBraille;
			}
			
			private final FromStyledTextToBraille fromStyledTextToBraille = new FromStyledTextToBraille() {
				public java.lang.Iterable<String> transform(java.lang.Iterable<CSSStyledText> styledText) {
					return translator.transform(styledText);
				}
			};
			
			@Override
			public String toString() {
				return Objects.toStringHelper(MTMTranslator.class.getSimpleName())
					.add("id", getIdentifier())
					.toString();
			}
		}
		
		@Reference(
			name = "DotifyTranslatorProvider",
			unbind = "unbindDotifyTranslatorProvider",
			service = DotifyTranslator.Provider.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		protected void bindDotifyTranslatorProvider(DotifyTranslator.Provider provider) {
			dotifyTranslatorProviders.add(provider);
		}
	
		protected void unbindDotifyTranslatorProvider(DotifyTranslator.Provider provider) {
			dotifyTranslatorProviders.remove(provider);
			dotifyTranslatorProvider.invalidateCache();
		}
	
		private List<TransformProvider<DotifyTranslator>> dotifyTranslatorProviders
		= new ArrayList<TransformProvider<DotifyTranslator>>();
		private TransformProvider.util.MemoizingProvider<DotifyTranslator> dotifyTranslatorProvider
		= memoize(dispatch(dotifyTranslatorProviders));
		
	}
}
