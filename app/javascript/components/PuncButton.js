import React from "react";
import PropTypes from "prop-types";

class PuncButton extends React.Component {
  asMarkup(text) {
    return { __html: text };
  }
  
  render () {
    const html = this.asMarkup(this.props.punc);
    return (
      <React.Fragment>
        <a
          className='punctuation-button'
          href='#'
          title="Click to reply here"
        >
          <span
            dangerouslySetInnerHTML={ html }
          />
        </a>
      </React.Fragment>
    );
  }
}

PuncButton.propTypes = {
  punc: PropTypes.string,
};
export default PuncButton
