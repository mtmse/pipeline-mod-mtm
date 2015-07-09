package se.mtm.pipeline.braille.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.net.URI;
import javax.xml.namespace.QName;

import static com.google.common.base.Objects.toStringHelper;
import com.google.common.base.Optional;
import com.google.common.collect.ImmutableMap;

import static org.daisy.pipeline.braille.css.Query.parseQuery;
import static org.daisy.pipeline.braille.common.util.Tuple3;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import org.daisy.pipeline.braille.common.CSSBlockTransform;
import org.daisy.pipeline.braille.common.LazyValue.ImmutableLazyValue;
import org.daisy.pipeline.braille.common.Transform;
import org.daisy.pipeline.braille.common.Transform.AbstractTransform;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.dispatch;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.logCreate;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.logSelect;
import static org.daisy.pipeline.braille.common.Transform.Provider.util.memoize;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import org.daisy.pipeline.braille.common.WithSideEffect;
import org.daisy.pipeline.braille.common.XProcTransform;
import org.daisy.pipeline.braille.dotify.DotifyTranslator;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.osgi.service.component.ComponentContext;

import org.slf4j.Logger;

public interface MTMCSSBlockTransform extends CSSBlockTransform, XProcTransform {
	
	@Component(
		name = "se.mtm.pipeline.braille.impl.MTMCSSBlockTransform.Provider",
		service = {
			XProcTransform.Provider.class,
			CSSBlockTransform.Provider.class
		}
	)
	public class Provider implements XProcTransform.Provider<MTMCSSBlockTransform>, CSSBlockTransform.Provider<MTMCSSBlockTransform> {
		
		private URI href;
		
		@Activate
		private void activate(ComponentContext context, final Map<?,?> properties) {
			href = asURI(context.getBundleContext().getBundle().getEntry("xml/block-translate.xpl"));
		}
		
		/**
		 * Recognized features:
		 *
		 * - translator: Will only match if the value is `mtm'.
		 * - locale: Will only match if the language subtag is 'sv'.
		 *
		 */
		public Iterable<MTMCSSBlockTransform> get(String query) {
			 return impl.get(query);
		 }
	
		public Transform.Provider<MTMCSSBlockTransform> withContext(Logger context) {
			return impl.withContext(context);
		}
	
		private Transform.Provider.MemoizingProvider<MTMCSSBlockTransform> impl = new ProviderImpl(null);
	
		private class ProviderImpl extends AbstractProvider<MTMCSSBlockTransform> {
			
			private final static String translatorQuery = "(locale:sv_SE)";
		
			private ProviderImpl(Logger context) {
				super(context);
			}
		
			protected Transform.Provider.MemoizingProvider<MTMCSSBlockTransform> _withContext(Logger context) {
				return new ProviderImpl(context);
			}
		
			protected final Iterable<WithSideEffect<MTMCSSBlockTransform,Logger>> __get(final String query) {
				return new ImmutableLazyValue<WithSideEffect<MTMCSSBlockTransform,Logger>>() {
					public WithSideEffect<MTMCSSBlockTransform,Logger> _apply() {
						return new WithSideEffect<MTMCSSBlockTransform,Logger>() {
							public MTMCSSBlockTransform _apply() {
								Map<String,Optional<String>> q = new HashMap<String,Optional<String>>(parseQuery(query));
								Optional<String> o;
								if ((o = q.remove("locale")) != null)
									if (!"sv".equals(parseLocale(o.get()).getLanguage()))
										throw new NoSuchElementException();
								if ((o = q.remove("translator")) != null)
									if (o.get().equals("mtm"))
										if (q.size() == 0) {
											try {
												applyWithSideEffect(
													logSelect(
														translatorQuery,
														dotifyTranslatorProvider.get(translatorQuery)).iterator().next()); }
											catch (NoSuchElementException e) {
												throw new NoSuchElementException(); }
											return applyWithSideEffect(
												logCreate(
													(MTMCSSBlockTransform)new TransformImpl(translatorQuery))); }
								throw new NoSuchElementException();
							}
						};
					}
				};
			}
		}
		
		private class TransformImpl extends AbstractTransform implements MTMCSSBlockTransform {
			
			private final Tuple3<URI,QName,Map<String,String>> xproc;
			
			private TransformImpl(String translatorQuery) {
				Map<String,String> options = ImmutableMap.of("query", translatorQuery);
				xproc = new Tuple3<URI,QName,Map<String,String>>(href, null, options);
			}
	
			public Tuple3<URI,QName,Map<String,String>> asXProc() {
				return xproc;
			}
	
			@Override
			public String toString() {
				return toStringHelper(MTMCSSBlockTransform.class.getSimpleName()).toString();
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
