import "@typespec/http";
import "@typespec/rest";
import "@typespec/versioning";
import "@azure-tools/typespec-azure-core";

using TypeSpec.Http;
using TypeSpec.Rest;
using TypeSpec.Versioning;

namespace Azure.OpenAI;

@added(ServiceApiVersions.v2023_06_01_Preview)
@doc("Ratings for the intensity and risk level of harmful content.")
union ContentFilterSeverity {
  string,

  @doc("""
    Content may be related to violence, self-harm, sexual, or hate categories but the terms
    are used in general, journalistic, scientific, medical, and similar professional contexts,
    which are appropriate for most audiences.
    """)
  safe: "safe",

  @doc("""
    Content that expresses prejudiced, judgmental, or opinionated views, includes offensive
    use of language, stereotyping, use cases exploring a fictional world (for example, gaming,
    literature) and depictions at low intensity.
    """)
  low: "low",

  @doc("""
    Content that uses offensive, insulting, mocking, intimidating, or demeaning language
    towards specific identity groups, includes depictions of seeking and executing harmful
    instructions, fantasies, glorification, promotion of harm at medium intensity.
    """)
  medium: "medium",

  @doc("""
    Content that displays explicit and severe harmful instructions, actions,
    damage, or abuse; includes endorsement, glorification, or promotion of severe
    harmful acts, extreme or illegal forms of harm, radicalization, or non-consensual
    power exchange or abuse.
    """)
  high: "high",
}

@added(ServiceApiVersions.v2023_06_01_Preview)
@doc("Information about filtered content severity level and if it has been filtered or not.")
model ContentFilterResult {
  ...FilteredResultBase;

  @doc("Ratings for the intensity and risk level of filtered content.")
  severity: ContentFilterSeverity;
}

alias FilteredResultBase = {
  @doc("A value indicating whether or not the content has been filtered.")
  filtered: boolean;
};

alias ContentFilterResultsBase = {
  @doc("""
    Describes language related to anatomical organs and genitals, romantic relationships,
     acts portrayed in erotic or affectionate terms, physical sexual acts, including
     those portrayed as an assault or a forced sexual violent act against one’s will,
     prostitution, pornography, and abuse.
    """)
  sexual?: ContentFilterResult;

  @doc("""
    Describes language related to physical actions intended to hurt, injure, damage, or
    kill someone or something; describes weapons, etc.
    """)
  violence?: ContentFilterResult;

  @doc("""
    Describes language attacks or uses that include pejorative or discriminatory language
    with reference to a person or identity group on the basis of certain differentiating
    attributes of these groups including but not limited to race, ethnicity, nationality,
    gender identity and expression, sexual orientation, religion, immigration status, ability
    status, personal appearance, and body size.
    """)
  hate?: ContentFilterResult;

  @doc("""
    Describes language related to physical actions intended to purposely hurt, injure,
    or damage one’s body, or kill oneself.
    """)
  @encodedName("application/json", "self_harm")
  selfHarm?: ContentFilterResult;

  @added(ServiceApiVersions.v2024_02_15_Preview)
  @doc("Describes whether profanity was detected.")
  profanity?: ContentFilterDetectionResult;

  @added(ServiceApiVersions.v2024_02_15_Preview)
  @encodedName("application/json", "custom_blocklists")
  @doc("Describes detection results against configured custom blocklists.")
  @typeChangedFrom(
    ServiceApiVersions.v2024_04_01_Preview,
    ContentFilterBlocklistIdResult[]
  )
  customBlocklists?: ContentFilterDetailedResults;

  @doc("""
    Describes an error returned if the content filtering system is
    down or otherwise unable to complete the operation in time.
    """)
  error?: Azure.Core.Foundations.Error;
};

@added(ServiceApiVersions.v2023_06_01_Preview)
@doc("Information about content filtering evaluated against input data to Azure OpenAI.")
model ContentFilterResultDetailsForPrompt {
  ...ContentFilterResultsBase;

  @doc("Whether a jailbreak attempt was detected in the prompt.")
  @added(ServiceApiVersions.v2024_02_15_Preview)
  jailbreak?: ContentFilterDetectionResult;

  @added(ServiceApiVersions.v2024_04_01_Preview)
  @encodedName("application/json", "indirect_attack")
  @doc("Whether an indirect attack was detected in the prompt.")
  indirectAttack?: ContentFilterDetectionResult;
}

@added(ServiceApiVersions.v2023_06_01_Preview)
@doc("Information about content filtering evaluated against generated model output.")
model ContentFilterResultsForChoice {
  ...ContentFilterResultsBase;

  @added(ServiceApiVersions.v2024_02_15_Preview)
  @encodedName("application/json", "protected_material_text")
  @doc("Information about detection of protected text material.")
  protectedMaterialText?: ContentFilterDetectionResult;

  @added(ServiceApiVersions.v2024_02_15_Preview)
  @encodedName("application/json", "protected_material_code")
  @doc("Information about detection of protected code material.")
  protectedMaterialCode?: ContentFilterCitedDetectionResult;

  @added(ServiceApiVersions.v2024_10_01_Preview)
  @encodedName("application/json", "ungrounded_material")
  @doc("Information about detection of ungrounded material.")
  ungroundedMaterial?: ContentFilterCompletionTextSpanResult;
}

@added(ServiceApiVersions.v2023_06_01_Preview)
@doc("""
  Content filtering results for a single prompt in the request.
  """)
model ContentFilterResultsForPrompt {
  @doc("The index of this prompt in the set of prompt results")
  @encodedName("application/json", "prompt_index")
  promptIndex: int32;

  @doc("Content filtering results for this prompt")
  @encodedName("application/json", "content_filter_results")
  contentFilterResults: ContentFilterResultDetailsForPrompt;
}

@added(ServiceApiVersions.v2024_02_15_Preview)
@doc("Represents the outcome of a detection operation performed by content filtering.")
model ContentFilterDetectionResult {
  ...FilteredResultBase;

  @doc("A value indicating whether detection occurred, irrespective of severity or whether the content was filtered.")
  detected: boolean;
}

@doc("Represents the outcome of a detection operation against protected resources as performed by content filtering.")
@added(ServiceApiVersions.v2024_02_15_Preview)
model ContentFilterCitedDetectionResult {
  ...ContentFilterDetectionResult;

  @encodedName("application/json", "URL")
  @doc("The internet location associated with the detection.")
  url?: url;

  @doc("The license description associated with the detection.")
  license?: string;
}

@added(ServiceApiVersions.v2024_10_01_Preview)
@doc("Describes a span within generated completion text.")
model ContentFilterCompletionTextSpanResult {
  ...ContentFilterDetectionResult;

  @doc("The collection of completion text spans.")
  details: ContentFilterCompletionTextSpan[];
}

@added(ServiceApiVersions.v2024_10_01_Preview)
@doc("Describes a span within generated completion text. Offset 0 is the first UTF32 code point of the completion text.")
model ContentFilterCompletionTextSpan {
  @doc("Offset of the UTF32 code point which begins the span.")
  @encodedName("application/json", "completion_start_offset")
  completionStartOffset: int32;

  @doc("""
    Offset of the first UTF32 code point which is excluded from the span. 
    This field is always equal to completion_start_offset for empty spans. 
    This field is always larger than completion_start_offset for non-empty spans.
    """)
  @encodedName("application/json", "completion_end_offset")
  completionEndOffset: int32;
}

@doc("Represents the outcome of an evaluation against a custom blocklist as performed by content filtering.")
@added(ServiceApiVersions.v2024_02_15_Preview)
model ContentFilterBlocklistIdResult {
  ...FilteredResultBase;

  @doc("The ID of the custom blocklist evaluated.")
  id: string;
}

@doc("Represents a structured collection of result details for content filtering.")
@added(ServiceApiVersions.v2024_04_01_Preview)
model ContentFilterDetailedResults {
  ...FilteredResultBase;

  @doc("The collection of detailed blocklist result information.")
  @madeRequired(ServiceApiVersions.v2024_10_01_Preview)
  details: ContentFilterBlocklistIdResult[];
}
