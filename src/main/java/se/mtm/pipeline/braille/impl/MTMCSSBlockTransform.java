package se.mtm.pipeline.braille.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.net.URI;
import javax.xml.namespace.QName;

import com.google.common.base.Objects;
import com.google.common.base.Optional;
import com.google.common.collect.ImmutableMap;

import static org.daisy.pipeline.braille.css.Query.parseQuery;
import static org.daisy.pipeline.braille.common.util.Tuple3;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.common.AbstractTransform;
import org.daisy.pipeline.braille.common.AbstractTransform.Provider.util.Function;
import org.daisy.pipeline.braille.common.AbstractTransform.Provider.util.Iterables;
import static org.daisy.pipeline.braille.common.AbstractTransform.Provider.util.Iterables.transform;
import static org.daisy.pipeline.braille.common.AbstractTransform.Provider.util.logCreate;
import static org.daisy.pipeline.braille.common.AbstractTransform.Provider.util.logSelect;
import org.daisy.pipeline.braille.common.CSSBlockTransform;
import org.daisy.pipeline.braille.common.TextTransform;
import org.daisy.pipeline.braille.common.Transform;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.dispatch;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.memoize;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import org.daisy.pipeline.braille.common.XProcTransform;
import org.daisy.pipeline.braille.dotify.DotifyTranslator;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.osgi.service.component.ComponentContext;

public interface MTMCSSBlockTransform extends CSSBlockTransform, XProcTransform {
	
	@Component(
		name = "se.mtm.pipeline.braille.impl.MTMCSSBlockTransform.Provider",
		service = {
			XProcTransform.Provider.class,
			CSSBlockTransform.Provider.class
		}
	)
	public class Provider extends AbstractTransform.Provider<MTMCSSBlockTransform>
	                      implements XProcTransform.Provider<MTMCSSBlockTransform>, CSSBlockTransform.Provider<MTMCSSBlockTransform> {
		
		private URI href;
		
		@Activate
		private void activate(ComponentContext context, final Map<?,?> properties) {
			href = asURI(context.getBundleContext().getBundle().getEntry("xml/block-translate.xpl"));
		}
		
		private final static String translatorQuery = "(locale:sv_SE)";
		
		private final static Iterable<MTMCSSBlockTransform> empty = Iterables.<MTMCSSBlockTransform>empty();
		
		/**
		 * Recognized features:
		 *
		 * - translator: Will only match if the value is `mtm'.
		 * - locale: Will only match if the language subtag is 'sv'.
		 *
		 */
		protected final Iterable<MTMCSSBlockTransform> _get(final String query) {
			Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
			Optional<String> o;
			if ((o = q.remove("locale")) != null)
				if (!"sv".equals(parseLocale(o.get()).getLanguage()))
					return empty;
			if ((o = q.remove("translator")) != null)
				if (o.get().equals("mtm"))
					if (q.size() == 0) {
						return transform(
							logSelect(translatorQuery, dotifyTranslatorProvider),
							new Function<DotifyTranslator,MTMCSSBlockTransform>() {
								public MTMCSSBlockTransform _apply(DotifyTranslator translator) {
									return __apply(logCreate(new TransformImpl(translatorQuery, translator))); }}); };
			return empty;
		}
		
		private class TransformImpl extends AbstractTransform implements MTMCSSBlockTransform {
			
			private final DotifyTranslator translator;
			private final Tuple3<URI,QName,Map<String,String>> xproc;
			
			private TransformImpl(String translatorQuery, DotifyTranslator translator) {
				Map<String,String> options = ImmutableMap.of("query", translatorQuery);
				xproc = new Tuple3<URI,QName,Map<String,String>>(href, null, options);
				this.translator = translator;
			}
			
			public TextTransform asTextTransform() {
				return translator;
			}
			
			public Tuple3<URI,QName,Map<String,String>> asXProc() {
				return xproc;
			}
			
			@Override
			public String toString() {
				return Objects.toStringHelper(MTMCSSBlockTransform.class.getSimpleName()).toString();
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
	
		private List<Transform.Provider<DotifyTranslator>> dotifyTranslatorProviders
		= new ArrayList<Transform.Provider<DotifyTranslator>>();
		private Transform.Provider.MemoizingProvider<DotifyTranslator> dotifyTranslatorProvider
		= memoize(dispatch(dotifyTranslatorProviders));
		
	}
}
